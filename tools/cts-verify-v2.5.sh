#!/bin/bash
# CTS 題目驗證腳本 v2.6.1 — 修正 VirtualDisplayTest instant mode 問題
# 更新日期: 2026-02-22
# 變更:
#   v2.6.1: 修正 VirtualDisplayTest 測試被過濾問題（使用 CtsDisplayTestCases）
#   v2.6.0: 加入鎖文件機制（防止多進程）、步驟狀態記錄（斷點續跑）、Hang 檢測
#   v2.5.4: 移除 ccache 相關代碼（AOSP 14+ 不使用）、增強 trap cleanup（防卡 bootloader）
#   v2.5.3: ccache 命中率改為顯示「當前 build」專屬數據（記錄基準值，算差異）
#   v2.5.2: build 進度 webhook 加入 ccache 命中率
#   v2.5.1: 加入 build 進度 webhook（每 3 分鐘報告）、cleanup 時終止子進程
#   v2.5: 根據實驗數據優化等待時間、加入 Pre-flash 健康檢查、flashall 超時保護
#         改用邏輯等待（sys.boot_completed）替代固定 sleep
#   v2.4: 加入 trap cleanup、fastboot timeout+重試、adb wait-for-device 超時
#   v2.3: PIPESTATUS 修正、patch 自動檢測、cts_log_start
#
# 實驗數據（2026-02-20）:
#   - Flash 時間: 102s（穩定）
#   - ADB 出現: Flash 後 +34s
#   - Boot 完成: +50s (27161) / +38s (2B231)
#   - 結論: 必須用邏輯等待，不能用固定秒數
#
# 用法: cts-verify-v2.5.sh <題目路徑> [題目路徑...]
# 範例: CTS_DEVICE=27161FDH20031X ./cts-verify-v2.5.sh domains/display/hard/Q005

LOG_FILE="/tmp/cts_verify.log"
DEVICE="${CTS_DEVICE:-27161FDH20031X}"

# ============================================
# PATH 設定（確保 fastboot/adb 可用）
# ============================================
export PATH="$HOME/Android/Sdk/platform-tools:$PATH"

# ============================================
# 時間常數（根據實驗數據 2026-02-20）
# ============================================
FLASH_TIMEOUT=300           # Flash 超時（改成 300s，避免 super partition 傳輸超時）
BOOTLOADER_TIMEOUT=30       # 進入 bootloader 超時
ADB_APPEAR_TIMEOUT=60       # ADB 出現超時（實測 34s，給 1.8x 餘量）
BOOT_COMPLETE_TIMEOUT=90    # Boot 完成超時（實測 50s，給 1.8x 餘量）
BOOT_CHECK_INTERVAL=2       # Boot 完成檢查間隔（秒）
PRE_FLASH_ADB_TIMEOUT=10    # Pre-flash ADB 檢查超時
USB_COOLDOWN=0              # USB 冷卻期（秒），設 0 關閉，建議 120 如果遇到 USB 問題
LOCK_TIMEOUT=1800           # 鎖超時（秒），超過視為 hang（預設 30 分鐘）

# ============================================
# v2.6.0 鎖文件機制
# ============================================
LOCK_DIR="/tmp/cts_verify_locks"
mkdir -p "$LOCK_DIR"

# 計算 patch 的 hash（用於判斷是否需要重新 build）
get_patch_hash() {
    local patch_file="$1"
    if [ -f "$patch_file" ]; then
        md5sum "$patch_file" | cut -d' ' -f1
    else
        echo "no_patch"
    fi
}

# 獲取鎖文件路徑
get_lock_file() {
    local q_dir="$1"
    local q_id=$(basename "$q_dir")
    echo "$LOCK_DIR/${q_id}.lock"
}

# 獲取狀態文件路徑
get_state_file() {
    local q_dir="$1"
    local q_id=$(basename "$q_dir")
    echo "$LOCK_DIR/${q_id}.state"
}

# 檢查並獲取鎖
acquire_lock() {
    local q_dir="$1"
    local lock_file=$(get_lock_file "$q_dir")
    local q_id=$(basename "$q_dir")
    
    if [ -f "$lock_file" ]; then
        # 讀取鎖信息
        local lock_pid=$(jq -r '.pid' "$lock_file" 2>/dev/null)
        local lock_time=$(jq -r '.start_time' "$lock_file" 2>/dev/null)
        local lock_device=$(jq -r '.device' "$lock_file" 2>/dev/null)
        
        # 檢查進程是否還在運行
        if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
            # 進程還在，檢查是否超時
            local lock_epoch=$(date -d "$lock_time" +%s 2>/dev/null || echo 0)
            local now_epoch=$(date +%s)
            local elapsed=$((now_epoch - lock_epoch))
            
            if [ $elapsed -gt $LOCK_TIMEOUT ]; then
                log "[$q_id] ⚠️ 檢測到 hang（已運行 ${elapsed}s > ${LOCK_TIMEOUT}s），強制清理鎖"
                notify "⚠️ **$q_id** 檢測到 hang，強制清理鎖"
                kill -9 "$lock_pid" 2>/dev/null
                rm -f "$lock_file"
            else
                log "[$q_id] ❌ 驗證已在運行中 (PID: $lock_pid, 設備: $lock_device, 已運行: ${elapsed}s)"
                notify "❌ **$q_id** 驗證已在運行中 (PID: $lock_pid)"
                return 1
            fi
        else
            # 進程不存在，清理過時的鎖
            log "[$q_id] ⚠️ 發現過時的鎖（進程 $lock_pid 已不存在），清理"
            rm -f "$lock_file"
        fi
    fi
    
    # 創建鎖文件
    cat > "$lock_file" << EOF
{
  "pid": $$,
  "device": "$DEVICE",
  "start_time": "$(date -Iseconds)",
  "question": "$q_dir"
}
EOF
    log "[$q_id] ✓ 獲取鎖成功 (PID: $$)"
    return 0
}

# 釋放鎖
release_lock() {
    local q_dir="$1"
    local lock_file=$(get_lock_file "$q_dir")
    local q_id=$(basename "$q_dir")
    
    if [ -f "$lock_file" ]; then
        rm -f "$lock_file"
        log "[$q_id] ✓ 釋放鎖"
    fi
}

# 更新步驟狀態
update_state() {
    local q_dir="$1"
    local step="$2"
    local status="$3"
    local state_file=$(get_state_file "$q_dir")
    local q_id=$(basename "$q_dir")
    local patch_hash=$(get_patch_hash "$q_dir/bug.patch")
    
    # 讀取或創建狀態
    local state="{}"
    if [ -f "$state_file" ]; then
        state=$(cat "$state_file")
    fi
    
    # 更新狀態
    state=$(echo "$state" | jq --arg step "$step" --arg status "$status" \
        --arg time "$(date -Iseconds)" --arg hash "$patch_hash" \
        --arg device "$DEVICE" '
        .patch_hash = $hash |
        .device = $device |
        .last_update = $time |
        .steps[$step] = {status: $status, time: $time}
    ')
    
    echo "$state" > "$state_file"
    log "[$q_id] 狀態更新: $step=$status"
}

# 獲取步驟狀態
get_step_status() {
    local q_dir="$1"
    local step="$2"
    local state_file=$(get_state_file "$q_dir")
    
    if [ -f "$state_file" ]; then
        jq -r ".steps.\"$step\".status // \"pending\"" "$state_file"
    else
        echo "pending"
    fi
}

# 檢查是否可以跳過步驟（基於 patch hash）
can_skip_build() {
    local q_dir="$1"
    local state_file=$(get_state_file "$q_dir")
    local q_id=$(basename "$q_dir")
    
    if [ ! -f "$state_file" ]; then
        return 1  # 沒有狀態文件，不能跳過
    fi
    
    local saved_hash=$(jq -r '.patch_hash // ""' "$state_file")
    local current_hash=$(get_patch_hash "$q_dir/bug.patch")
    local build_status=$(get_step_status "$q_dir" "build")
    
    if [ "$saved_hash" = "$current_hash" ] && [ "$build_status" = "done" ]; then
        log "[$q_id] ✓ Patch 未變更且 build 已完成，可以跳過 build"
        return 0
    else
        log "[$q_id] Patch hash: saved=$saved_hash, current=$current_hash, build=$build_status"
        return 1
    fi
}

# 清理狀態（驗證完成後）
clear_state() {
    local q_dir="$1"
    local state_file=$(get_state_file "$q_dir")
    rm -f "$state_file"
}

# 追蹤當前正在驗證的題目（用於 cleanup 時釋放鎖）
CURRENT_QUESTION_DIR=""

# ============================================
# v2.6.0 增強：設備保護 + 鎖釋放
# ============================================
cleanup() {
    log "腳本中斷，嘗試救回設備..."
    
    # v2.6.0: 釋放當前題目的鎖
    if [ -n "$CURRENT_QUESTION_DIR" ]; then
        release_lock "$CURRENT_QUESTION_DIR"
    fi
    
    # 停止 build 監控
    [ -n "$BUILD_MONITOR_PID" ] && kill $BUILD_MONITOR_PID 2>/dev/null
    
    # 終止相關子進程（ninja build 等）
    pkill -P $$ 2>/dev/null
    
    # v2.5.4: 嘗試 fastboot reboot（帶超時和重試）
    timeout 30 fastboot -s $DEVICE reboot 2>/dev/null || {
        # 第一次失敗，重試一次
        sleep 3
        timeout 30 fastboot -s $DEVICE reboot 2>/dev/null || true
    }
    
    # 嘗試 adb reboot（如果在 adb 模式）
    timeout 10 adb -s $DEVICE reboot 2>/dev/null || true
}
trap cleanup INT TERM EXIT

SANDBOX="$HOME/develop_claw/aosp-sandbox-2"
CTS_PATH="$HOME/android-cts"
BACKUP_TOOL="$HOME/develop_claw/cts-exam-bank/tools/backup-cts-results.sh"
WEBHOOK_URL="https://discordapp.com/api/webhooks/1473692492133302322/X729Q-6zFcqrXu68SFxMBXMJJy99s9gqj3llCzeCdKMQy_vg2_JYWuSGeVIRX5Y6lol8"
WIFI_SSID="TP-LINK_5G_BA98"
WIFI_PASSWORD="2192191414"

export USE_ATS=false
export ANDROID_PRODUCT_OUT="$SANDBOX/out/target/product/panther"
export PATH="$SANDBOX/out/host/linux-x86/bin:$HOME/Android/Sdk/platform-tools:$PATH"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

notify() {
    local message="$1"
    curl -s -X POST "$WEBHOOK_URL" \
        -H "Content-Type: application/json" \
        -d "{\"content\":\"$message\"}" > /dev/null 2>&1
}

# ============================================
# v2.5.1 Build 進度監控（背景執行）
# v2.5.4: 移除 ccache 相關顯示
# ============================================
BUILD_MONITOR_PID=""

start_build_monitor() {
    local q_id="$1"
    local interval="${2:-180}"  # 預設每 3 分鐘報告一次
    
    (
        local last_progress=""
        while true; do
            sleep "$interval"
            
            # 檢查 ninja 是否還在跑
            if ! pgrep -f "ninja.*combined-aosp" > /dev/null; then
                break
            fi
            
            # 從 ninja 輸出擷取進度
            local progress=$(ps aux | grep -E "ninja.*combined-aosp" | grep -v grep | head -1)
            if [ -n "$progress" ]; then
                # 嘗試從最近的 build.log 擷取進度行
                local progress_line=$(tail -20 "$SANDBOX/build.log" 2>/dev/null | grep -E "^\[.*%.*\]" | tail -1)
                if [ -n "$progress_line" ] && [ "$progress_line" != "$last_progress" ]; then
                    last_progress="$progress_line"
                    notify "🔧 **$q_id** build 進度: \`$progress_line\`"
                else
                    # 如果沒有進度行，報告 ninja 仍在運行
                    local elapsed=$(ps -o etimes= -p $(pgrep -f "ninja.*combined-aosp" | head -1) 2>/dev/null | tr -d ' ')
                    if [ -n "$elapsed" ]; then
                        local mins=$((elapsed / 60))
                        notify "🔧 **$q_id** build 進行中... (已 ${mins} 分鐘)"
                    fi
                fi
            fi
        done
    ) &
    BUILD_MONITOR_PID=$!
    log "[$q_id] Build 監控啟動 (PID: $BUILD_MONITOR_PID, 間隔: ${interval}s)"
}

stop_build_monitor() {
    if [ -n "$BUILD_MONITOR_PID" ]; then
        kill $BUILD_MONITOR_PID 2>/dev/null
        wait $BUILD_MONITOR_PID 2>/dev/null
        BUILD_MONITOR_PID=""
    fi
}

# ============================================
# v2.5 Pre-flash 健康檢查
# ============================================
pre_flash_health_check() {
    local q_id="$1"
    log "[$q_id] Pre-flash 健康檢查..."
    
    # 檢查設備是否可見
    if ! adb devices | grep -q "$DEVICE"; then
        log "[$q_id] ⚠️ 設備 $DEVICE 不在 adb devices 中"
        
        # 嘗試在 fastboot 模式找
        if fastboot devices | grep -q "$DEVICE"; then
            log "[$q_id] 設備在 fastboot 模式，嘗試 reboot..."
            timeout 30 fastboot -s $DEVICE reboot 2>/dev/null
            sleep 30
            timeout 60 adb -s $DEVICE wait-for-device
        else
            log "[$q_id] ❌ 設備完全不可見，請檢查 USB 連接"
            notify "❌ **$q_id** 設備不可見，請檢查 USB"
            return 1
        fi
    fi
    
    # 檢查 adb 通訊正常
    if ! timeout $PRE_FLASH_ADB_TIMEOUT adb -s $DEVICE shell echo "ping" >/dev/null 2>&1; then
        log "[$q_id] ⚠️ ADB 無響應，嘗試重啟 adb server..."
        adb kill-server
        sleep 2
        adb start-server
        sleep 3
        
        if ! timeout $PRE_FLASH_ADB_TIMEOUT adb -s $DEVICE shell echo "ping" >/dev/null 2>&1; then
            log "[$q_id] ❌ ADB 仍無響應"
            notify "❌ **$q_id** ADB 無響應"
            return 1
        fi
    fi
    
    log "[$q_id] ✓ Pre-flash 健康檢查通過"
    return 0
}

# ============================================
# v2.5 等待 boot 完成（邏輯等待）
# ============================================
wait_for_boot_complete() {
    local q_id="$1"
    local timeout_sec="$2"
    local start_time=$(date +%s)
    
    log "[$q_id] 等待系統啟動完成（最多 ${timeout_sec}s）..."
    
    while true; do
        local elapsed=$(( $(date +%s) - start_time ))
        
        if [ $elapsed -gt $timeout_sec ]; then
            log "[$q_id] ❌ Boot 超時（${timeout_sec}s）"
            return 1
        fi
        
        # 檢查 sys.boot_completed
        local boot_completed=$(adb -s $DEVICE shell getprop sys.boot_completed 2>/dev/null | tr -d '\r\n')
        
        if [ "$boot_completed" = "1" ]; then
            log "[$q_id] ✓ 系統啟動完成（${elapsed}s）"
            return 0
        fi
        
        sleep $BOOT_CHECK_INTERVAL
    done
}

# ============================================
# v2.5.4: 簡化編譯環境設定（移除 ccache）
# ============================================
setup_build_env() {
    log "設定編譯環境..."
    
    # 固定 BUILD_DATETIME（消除時間導致的差異）
    export BUILD_DATETIME_FILE="$SANDBOX/.build_datetime"
    if [ ! -f "$BUILD_DATETIME_FILE" ]; then
        echo "$(date +%s)" > "$BUILD_DATETIME_FILE"
        log "✓ 建立 BUILD_DATETIME_FILE"
    fi
    
    export BUILD_NUMBER="eng.$(whoami).$(date +%Y%m%d)"
}

wait_for_build() {
    log "等待現有 build 完成..."
    notify "⏳ 等待現有 build 完成..."
    while ps aux | grep -E "soong_ui --make-mode|ninja.*combined-aosp" | grep -v grep > /dev/null; do
        sleep 30
        log "Build 仍在進行中..."
    done
    log "現有 build 已完成"
    notify "✅ 現有 build 已完成"
}

# ============================================
# Build（整合 Level 1 排查）
# v2.5.4: 移除 ccache 相關顯示
# ============================================
do_build() {
    local q_id="$1"
    log "[$q_id] 開始 build..."
    notify "🔨 **$q_id** 開始 build..."
    
    cd "$SANDBOX"
    
    # 啟動背景進度監控（每 3 分鐘報告）
    start_build_monitor "$q_id" 180
    
    local start_time=$(date +%s)
    # 調用 aosp-incremental-build skill
    AOSP_ROOT="$SANDBOX" ~/clawd/skills/aosp-incremental-build/scripts/daily_build.sh \
        aosp_panther-ap2a-userdebug 2>&1 | tee -a "$LOG_FILE"
    local build_result=${PIPESTATUS[0]}
    local end_time=$(date +%s)
    local duration=$(( (end_time - start_time) / 60 ))
    
    # 停止進度監控
    stop_build_monitor
    
    if [ $build_result -eq 0 ]; then
        log "[$q_id] Build 完成，耗時 ${duration} 分鐘"
        notify "✅ **$q_id** build 完成，耗時 **${duration} 分鐘**"
        return 0
    fi
    
    # Build 失敗，套用 Level 1 排查
    log "[$q_id] Build 失敗，啟動 Level 1 排查..."
    notify "⚠️ **$q_id** build 失敗，嘗試 Level 1 排查（clean 模組後重試）..."
    
    # 從錯誤中提取失敗的模組
    local failed_modules=$(grep -E "FAILED:|error:" "$LOG_FILE" | tail -10 | \
        grep -oE "[A-Za-z_-]+\.so|[A-Za-z_-]+\.apk|[A-Za-z_-]+\.jar" | \
        sed 's/\.so//;s/\.apk//;s/\.jar//' | sort -u | head -3)
    
    if [ -z "$failed_modules" ]; then
        failed_modules="framework services"
        log "[$q_id] 無法識別失敗模組，嘗試清理: $failed_modules"
    else
        log "[$q_id] 識別到失敗模組: $failed_modules"
    fi
    
    for module in $failed_modules; do
        log "[$q_id] Level 1: 清理模組 $module..."
        m clean-$module 2>/dev/null
    done
    
    # 重試 build
    log "[$q_id] Level 1: 重試 build..."
    start_time=$(date +%s)
    AOSP_ROOT="$SANDBOX" ~/clawd/skills/aosp-incremental-build/scripts/daily_build.sh \
        aosp_panther-ap2a-userdebug 2>&1 | tee -a "$LOG_FILE"
    build_result=${PIPESTATUS[0]}
    end_time=$(date +%s)
    duration=$(( (end_time - start_time) / 60 ))
    
    if [ $build_result -eq 0 ]; then
        log "[$q_id] Level 1 排查後 build 成功，耗時 ${duration} 分鐘"
        notify "✅ **$q_id** Level 1 排查成功，build 完成，耗時 **${duration} 分鐘**"
        return 0
    else
        log "[$q_id] Level 1 排查後仍然失敗"
        notify "❌ **$q_id** Level 1 排查失敗，需要人工檢查 log"
        return 1
    fi
}

# ============================================
# v2.5 flash_device（根據實驗數據優化）
# ============================================
flash_device() {
    local q_id="$1"
    
    # Pre-flash 健康檢查
    pre_flash_health_check "$q_id" || return 1
    
    log "[$q_id] 開始 flash 設備 $DEVICE..."
    notify "📱 **$q_id** 開始 flash 設備..."
    
    # 進入 bootloader
    log "[$q_id] 重啟到 bootloader..."
    adb -s $DEVICE reboot bootloader
    
    # v2.5.4: 等待進入 bootloader（用輪詢，兼容性更好）
    log "[$q_id] 等待進入 bootloader（最多 ${BOOTLOADER_TIMEOUT}s）..."
    local wait_start=$(date +%s)
    for i in $(seq 1 $BOOTLOADER_TIMEOUT); do
        if fastboot -s $DEVICE getvar product 2>&1 | grep -q "product:"; then
            log "[$q_id] ✓ 設備已進入 fastboot"
            break
        fi
        local elapsed=$(($(date +%s) - wait_start))
        if [ $elapsed -gt $BOOTLOADER_TIMEOUT ]; then
            log "[$q_id] ❌ 進入 bootloader 超時"
            notify "❌ **$q_id** 進入 bootloader 超時"
            return 1
        fi
        sleep 1
    done
    
    # 再次確認 fastboot 通訊正常
    if ! timeout 10 fastboot -s $DEVICE getvar product >/dev/null 2>&1; then
        log "[$q_id] ⚠️ Fastboot 通訊異常，可能是 USB 問題"
        notify "⚠️ **$q_id** Fastboot 通訊異常，請檢查 USB"
        return 1
    fi
    
    # Flash 加超時保護（實測 102s，給 180s）
    log "[$q_id] 開始 flash（超時 ${FLASH_TIMEOUT}s）..."
    local flash_start=$(date +%s)
    
    timeout $FLASH_TIMEOUT fastboot -s $DEVICE flashall -w 2>&1 | tee -a "$LOG_FILE"
    local flash_result=${PIPESTATUS[0]}
    
    local flash_end=$(date +%s)
    local flash_duration=$((flash_end - flash_start))
    log "[$q_id] Flash 耗時: ${flash_duration}s"
    
    if [ $flash_result -eq 124 ]; then
        log "[$q_id] ❌ Flash 超時（${FLASH_TIMEOUT}s）！可能是 USB 問題"
        notify "❌ **$q_id** flash 超時！請檢查 USB 連接"
        return 1
    elif [ $flash_result -ne 0 ]; then
        log "[$q_id] ❌ Flash 失敗！返回值: $flash_result"
        notify "❌ **$q_id** flash 失敗！"
        return 1
    fi
    
    log "[$q_id] ✓ Flash 完成，等待設備重啟..."
    notify "✅ **$q_id** flash 完成（${flash_duration}s），等待設備開機..."
    
    # 等待 ADB 出現（實測 34s，給 60s）
    log "[$q_id] 等待 ADB 出現（最多 ${ADB_APPEAR_TIMEOUT}s）..."
    if ! timeout $ADB_APPEAR_TIMEOUT adb -s $DEVICE wait-for-device; then
        log "[$q_id] ❌ ADB 出現超時"
        notify "⚠️ **$q_id** ADB 出現超時，設備可能卡在 bootloader"
        
        # 嘗試從 fastboot 重啟
        timeout $BOOTLOADER_TIMEOUT fastboot -s $DEVICE reboot 2>/dev/null || true
        sleep $PRE_FLASH_ADB_TIMEOUT
        
        if ! timeout $ADB_APPEAR_TIMEOUT adb -s $DEVICE wait-for-device; then
            log "[$q_id] ❌ 設備無法恢復"
            notify "❌ **$q_id** 設備無法恢復，請手動檢查"
            return 1
        fi
    fi
    
    # 使用邏輯等待替代固定 sleep（實測 boot 完成 +50s）
    wait_for_boot_complete "$q_id" "$BOOT_COMPLETE_TIMEOUT" || {
        notify "⚠️ **$q_id** Boot 超時，嘗試繼續..."
        # 不直接 return，嘗試繼續
    }
    
    log "[$q_id] 設備已就緒"
    notify "📱 **$q_id** 設備已就緒"
    
    # USB 冷卻期（可選）
    if [ "$USB_COOLDOWN" -gt 0 ]; then
        log "[$q_id] USB 冷卻期（${USB_COOLDOWN}s）..."
        adb kill-server
        sleep $USB_COOLDOWN
        adb start-server
        sleep 3
    fi
    
    # 設置 WiFi（CTS 需要網路連線）
    log "[$q_id] 設置 WiFi: $WIFI_SSID"
    notify "📶 **$q_id** 設置 WiFi..."
    
    # 先確認設備在線
    if ! adb -s $DEVICE get-state 2>/dev/null | grep -q "device"; then
        log "[$q_id] ❌ 設備不在線，無法設置 WiFi"
        notify "❌ **$q_id** 設備不在線（adb 找不到），跳過此題"
        return 1
    fi
    
    sleep 5
    adb -s $DEVICE root
    sleep 3
    adb -s $DEVICE shell cmd wifi set-wifi-enabled enabled 2>&1 | tee -a "$LOG_FILE"
    sleep 3
    
    # 嘗試連接 WiFi（最多重試 5 次）
    local wifi_connected=false
    for attempt in 1 2 3 4 5; do
        log "[$q_id] WiFi 連接嘗試 $attempt/5..."
        adb -s $DEVICE shell cmd wifi connect-network "$WIFI_SSID" wpa2 "$WIFI_PASSWORD" 2>&1 | tee -a "$LOG_FILE"
        sleep 8
        
        local wifi_status=$(adb -s $DEVICE shell cmd wifi status 2>&1)
        if echo "$wifi_status" | grep -qi "Wifi is connected"; then
            wifi_connected=true
            log "[$q_id] WiFi 連接成功！"
            notify "✅ **$q_id** WiFi 已連接"
            break
        fi
        log "[$q_id] WiFi 尚未連接，等待重試..."
        sleep 5
    done
    
    if [ "$wifi_connected" = false ]; then
        log "[$q_id] WiFi 連接失敗，無法繼續 CTS"
        notify "❌ **$q_id** WiFi 連接失敗，跳過此題"
        return 1
    fi
    
    return 0
}

run_cts() {
    local q_id="$1"
    local test_method="$2"
    
    log "[$q_id] 開始執行 CTS: $test_method"
    notify "🧪 **$q_id** 開始執行 CTS..."
    
    # 記錄 CTS 開始位置（避免 race condition）
    local cts_log_start=$([ -f "$LOG_FILE" ] && wc -l < "$LOG_FILE" || echo "0")
    
    (
        unset ANDROID_BUILD_TOP ANDROID_HOST_OUT ANDROID_PRODUCT_OUT OUT_DIR TARGET_PRODUCT TARGET_BUILD_VARIANT
        cd "$CTS_PATH"
        
        if [ ! -f "./tools/cts-tradefed" ]; then
            echo "[$q_id] 錯誤：找不到 cts-tradefed！"
            exit 1
        fi
        
        # 使用 meta.json 中指定的 cts_module
        local cts_module
        cts_module=$(grep -o '"cts_module"[[:space:]]*:[[:space:]]*"[^"]*"' "$question_dir/meta.json" | cut -d'"' -f4)
        if [[ -z "$cts_module" ]]; then
            cts_module="CtsDisplayTestCases"
        fi
        echo "[$q_id] 使用模組: $cts_module"
        
        ./tools/cts-tradefed run cts -m "$cts_module" -t "$test_method" -s $DEVICE
    ) 2>&1 | tee -a "$LOG_FILE"
    local cts_result=${PIPESTATUS[0]}
    
    if [ $cts_result -ne 0 ]; then
        log "[$q_id] CTS 執行失敗：返回值 $cts_result"
        notify "❌ **$q_id** CTS 執行失敗！"
        return 1
    fi
    
    if grep -q "ClassNotFoundException\|Could not find or load main class" "$LOG_FILE"; then
        log "[$q_id] CTS 執行失敗：Java class 載入錯誤"
        notify "❌ **$q_id** CTS 執行失敗：Java class 載入錯誤"
        return 1
    fi
    
    # 解析 CTS 結果（只讀取本次 CTS 的輸出）
    local cts_output=$(tail -n +$((cts_log_start + 1)) "$LOG_FILE")
    local passed=$(echo "$cts_output" | grep -E "^PASSED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
    local failed=$(echo "$cts_output" | grep -E "^FAILED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
    passed=${passed:-0}
    failed=${failed:-0}
    
    if [ "$passed" = "0" ] && [ "$failed" = "0" ]; then
        log "[$q_id] CTS 結果異常：沒有任何測試執行"
        notify "❌ **$q_id** CTS 結果異常：沒有任何測試執行"
        return 1
    fi
    
    log "[$q_id] CTS 結果: Passed=$passed, Failed=$failed"
    
    if [ "$failed" -gt 0 ]; then
        notify "🧪 **$q_id** CTS: ✅ Passed: $passed | ❌ Failed: $failed（符合預期）"
    else
        notify "⚠️ **$q_id** CTS: ✅ Passed: $passed | ❌ Failed: $failed（注意：無失敗）"
    fi
    return 0
}

verify_question() {
    local q_dir="$1"
    
    # 轉成絕對路徑（避免 cd 後找不到）
    if [[ "$q_dir" != /* ]]; then
        q_dir="$(cd "$(dirname "$q_dir")" && pwd)/$(basename "$q_dir")"
    fi
    
    local q_id=$(basename "$q_dir")
    
    # 檢查題目目錄
    if [ ! -d "$q_dir" ]; then
        log "[$q_id] 錯誤：題目目錄不存在: $q_dir"
        notify "❌ **$q_id** 題目目錄不存在"
        return 1
    fi
    
    if [ ! -f "$q_dir/bug.patch" ] || [ ! -f "$q_dir/meta.json" ]; then
        log "[$q_id] 錯誤：缺少 bug.patch 或 meta.json"
        notify "❌ **$q_id** 缺少必要檔案"
        return 1
    fi
    
    # v2.6.0: 獲取鎖
    if ! acquire_lock "$q_dir"; then
        return 1
    fi
    CURRENT_QUESTION_DIR="$q_dir"
    
    log "========== 開始驗證 $q_id =========="
    log "[$q_id] 題目目錄: $q_dir"
    notify "🔄 ========== 開始驗證 **$q_id** =========="
    
    # 讀取 meta.json 獲取 test method
    local test_method=$(cat "$q_dir/meta.json" | grep '"cts_test"' | cut -d'"' -f4)
    log "[$q_id] CTS Test: $test_method"
    
    # v2.6.0: 檢查是否可以跳過 restore/patch/build
    local skip_build=false
    if can_skip_build "$q_dir"; then
        local flash_status=$(get_step_status "$q_dir" "flash")
        if [ "$flash_status" = "done" ]; then
            # Flash 也完成了，直接跳到 CTS
            log "[$q_id] ✓ Build 和 Flash 都已完成，跳過"
            notify "⏭️ **$q_id** 跳過 build/flash（已完成）"
        else
            # 只跳過 build，從 flash 開始
            log "[$q_id] ✓ Build 已完成，從 flash 繼續"
            notify "⏭️ **$q_id** 跳過 build（已完成），從 flash 繼續"
            skip_build=true
        fi
    fi
    
    if [ "$skip_build" = "false" ]; then
        # 還原 sandbox
        log "[$q_id] 還原 sandbox..."
        notify "🔄 **$q_id** 還原 sandbox..."
        update_state "$q_dir" "restore" "running"
        cd "$SANDBOX"
        repo forall -c 'git checkout .' 2>/dev/null
        rm -rf out/target/
        update_state "$q_dir" "restore" "done"
        
        # 套用 patch（自動檢測正確目錄）
        log "[$q_id] 套用 patch..."
        notify "📝 **$q_id** 套用 patch..."
        update_state "$q_dir" "patch" "running"
        
        # 嘗試從 sandbox 根目錄 apply
        if patch --dry-run -p1 < "$q_dir/bug.patch" > /dev/null 2>&1; then
            patch -p1 < "$q_dir/bug.patch" 2>&1 | tee -a "$LOG_FILE"
            if [ "${PIPESTATUS[0]}" -ne 0 ]; then
                log "[$q_id] ❌ Patch failed from sandbox root!"
                notify "❌ **$q_id** Patch 套用失敗！"
                update_state "$q_dir" "patch" "failed"
                release_lock "$q_dir"
                CURRENT_QUESTION_DIR=""
                return 1
            fi
            log "[$q_id] ✓ Patch applied from sandbox root"
        # 嘗試從 frameworks/base apply
        elif (cd frameworks/base && patch --dry-run -p1 < "$q_dir/bug.patch" > /dev/null 2>&1); then
            (cd frameworks/base && patch -p1 < "$q_dir/bug.patch") 2>&1 | tee -a "$LOG_FILE"
            if [ "${PIPESTATUS[0]}" -ne 0 ]; then
                log "[$q_id] ❌ Patch failed from frameworks/base!"
                notify "❌ **$q_id** Patch 套用失敗！"
                update_state "$q_dir" "patch" "failed"
                release_lock "$q_dir"
                CURRENT_QUESTION_DIR=""
                return 1
            fi
            log "[$q_id] ✓ Patch applied from frameworks/base"
        else
            log "[$q_id] ❌ Patch failed to apply!"
            notify "❌ **$q_id** Patch 套用失敗！"
            update_state "$q_dir" "patch" "failed"
            release_lock "$q_dir"
            CURRENT_QUESTION_DIR=""
            return 1
        fi
        update_state "$q_dir" "patch" "done"
        
        # Build
        update_state "$q_dir" "build" "running"
        if ! do_build "$q_id"; then
            update_state "$q_dir" "build" "failed"
            release_lock "$q_dir"
            CURRENT_QUESTION_DIR=""
            return 1
        fi
        update_state "$q_dir" "build" "done"
    fi
    
    # Flash
    update_state "$q_dir" "flash" "running"
    if ! flash_device "$q_id"; then
        update_state "$q_dir" "flash" "failed"
        release_lock "$q_dir"
        CURRENT_QUESTION_DIR=""
        return 1
    fi
    update_state "$q_dir" "flash" "done"
    
    # CTS
    update_state "$q_dir" "cts" "running"
    if ! run_cts "$q_id" "$test_method"; then
        update_state "$q_dir" "cts" "failed"
        release_lock "$q_dir"
        CURRENT_QUESTION_DIR=""
        return 1
    fi
    update_state "$q_dir" "cts" "done"
    
    # 備份 CTS 結果和 logs
    log "[$q_id] 備份 CTS 結果..."
    
    # 從路徑解析 domain 和 difficulty
    local domain=$(echo "$q_dir" | grep -oP 'domains/\K[^/]+')
    local difficulty=$(echo "$q_dir" | grep -oP 'domains/[^/]+/\K[^/]+')
    
    # 備份 results（使用 latest）
    mkdir -p "$q_dir/cts_results"
    local latest_result=$(readlink -f "$CTS_PATH/results/latest")
    if [ -d "$latest_result" ]; then
        cp -r "$latest_result"/* "$q_dir/cts_results/"
        log "[$q_id] ✓ 已備份 CTS results"
    fi
    
    # 備份 logs
    local latest_log=$(ls -td "$CTS_PATH/logs/"*/ 2>/dev/null | head -1)
    if [ -d "$latest_log" ]; then
        mkdir -p "$q_dir/cts_results/logs"
        cp -r "$latest_log"/* "$q_dir/cts_results/logs/"
        log "[$q_id] ✓ 已備份 CTS logs"
    fi
    
    # 建立備份 metadata
    cat > "$q_dir/cts_results/backup_metadata.json" << EOF
{
  "backup_time": "$(date -Iseconds)",
  "question": "$q_id",
  "domain": "$domain",
  "difficulty": "$difficulty"
}
EOF
    notify "📦 **$q_id** 已備份 CTS 結果和 logs"
    
    # 更新 meta.json
    if [ -f "$q_dir/meta.json" ]; then
        local today=$(date +%Y-%m-%d)
        # 解析 CTS 結果 - 優先從 test_result.xml 讀取
        local passed=0
        local failed=0
        local xml_file="$q_dir/cts_results/test_result.xml"
        
        if [ -f "$xml_file" ]; then
            # 從 XML Summary 解析
            passed=$(grep -oP 'Summary pass="\K\d+' "$xml_file" 2>/dev/null || echo "0")
            failed=$(grep -oP 'failed="\K\d+' "$xml_file" 2>/dev/null || echo "0")
            log "[$q_id] 從 test_result.xml 解析: passed=$passed, failed=$failed"
        else
            # Fallback: 從 log 解析
            passed=$(tail -50 "$LOG_FILE" | grep -E "^PASSED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
            failed=$(tail -50 "$LOG_FILE" | grep -E "^FAILED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
            log "[$q_id] 從 log 解析: passed=$passed, failed=$failed"
        fi
        local total=$((passed + failed))
        
        # 使用 jq 或 Python 更新
        # verified = true 當 failed > 0（bug 成功觸發測試失敗）
        local is_verified="false"
        if [ "$failed" -gt 0 ]; then
            is_verified="true"
        fi
        
        if command -v jq &> /dev/null; then
            local tmp_file=$(mktemp)
            jq --arg date "$today" --argjson passed "$passed" --argjson failed "$failed" --argjson total "$total" --argjson verified "$is_verified" '
                .verified = $verified |
                .verification_status = "complete" |
                .verification_date = $date |
                .cts_summary = {passed: $passed, failed: $failed, total: $total} |
                del(.verification_issues)
            ' "$q_dir/meta.json" > "$tmp_file" && mv "$tmp_file" "$q_dir/meta.json"
            log "[$q_id] ✓ 已更新 meta.json (jq, verified=$is_verified)"
        elif command -v python3 &> /dev/null; then
            python3 << PYEOF
import json
with open('$q_dir/meta.json', 'r') as f:
    data = json.load(f)
data['verified'] = $is_verified
data['verification_status'] = 'complete'
data['verification_date'] = '$today'
data['cts_summary'] = {'passed': $passed, 'failed': $failed, 'total': $total}
if 'verification_issues' in data:
    del data['verification_issues']
with open('$q_dir/meta.json', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
PYEOF
            log "[$q_id] ✓ 已更新 meta.json (python3, verified=$is_verified)"
        else
            log "[$q_id] ⚠️ jq/python3 未安裝，跳過 meta.json 更新"
        fi
    fi
    
    log "========== $q_id 驗證完成 =========="
    notify "🎉 **$q_id** 驗證完成！"
    
    # v2.6.0: 驗證成功，清理狀態和釋放鎖
    clear_state "$q_dir"
    release_lock "$q_dir"
    CURRENT_QUESTION_DIR=""
}

# ==================== 主流程 ====================

if [ $# -eq 0 ]; then
    echo "用法: $0 <題目路徑> [題目路徑...]"
    echo "範例: CTS_DEVICE=27161FDH20031X $0 domains/display/hard/Q005"
    echo ""
    echo "環境變數:"
    echo "  CTS_DEVICE      - 設備序號（預設: 27161FDH20031X）"
    echo "  USB_COOLDOWN    - USB 冷卻期秒數（預設: 0，建議遇到 USB 問題時設 120）"
    echo ""
    echo "時間常數（根據實驗數據 2026-02-20）:"
    echo "  FLASH_TIMEOUT=$FLASH_TIMEOUT"
    echo "  BOOTLOADER_TIMEOUT=$BOOTLOADER_TIMEOUT"
    echo "  ADB_APPEAR_TIMEOUT=$ADB_APPEAR_TIMEOUT"
    echo "  BOOT_COMPLETE_TIMEOUT=$BOOT_COMPLETE_TIMEOUT"
    echo "  LOCK_TIMEOUT=$LOCK_TIMEOUT (hang 檢測閾值)"
    echo ""
    echo "v2.6.0 新功能:"
    echo "  - 鎖文件機制：防止多個驗證同時運行"
    echo "  - 斷點續跑：patch 沒變時跳過 build，從失敗步驟繼續"
    echo "  - Hang 檢測：超過 LOCK_TIMEOUT 自動清理"
    echo "  - 狀態文件：$LOCK_DIR/<題目>.state"
    exit 1
fi

# 先把所有相對路徑轉成絕對路徑（避免 cd 後失效）
QUESTION_PATHS=()
for p in "$@"; do
    if [[ "$p" != /* ]]; then
        QUESTION_PATHS+=("$(pwd)/$p")
    else
        QUESTION_PATHS+=("$p")
    fi
done

> "$LOG_FILE"
log "=========================================="
log "CTS 驗證腳本 v2.5.4（移除 ccache、增強 cleanup）"
log "設備: $DEVICE"
log "題目: ${QUESTION_PATHS[*]}"
log "=========================================="
log "時間常數: FLASH=$FLASH_TIMEOUT, BOOTLOADER=$BOOTLOADER_TIMEOUT, ADB=$ADB_APPEAR_TIMEOUT, BOOT=$BOOT_COMPLETE_TIMEOUT"
notify "🚀 開始驗證: **${QUESTION_PATHS[*]}** (設備: $DEVICE)"

if ps aux | grep -E "soong_ui --make-mode|ninja.*combined-aosp" | grep -v grep > /dev/null; then
    wait_for_build
fi

for q_path in "${QUESTION_PATHS[@]}"; do
    verify_question "$q_path"
done

log "=========================================="
log "所有驗證完成！"
log "=========================================="
notify "🎊 **所有驗證完成！** Log: \`/tmp/cts_verify.log\`"
