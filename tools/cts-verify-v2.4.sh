#!/bin/bash
# CTS 題目驗證腳本 v2.4 — 加入設備保護機制
# 更新日期: 2026-02-19
# 變更:
#   v2.4: 加入 trap cleanup、fastboot timeout+重試、adb wait-for-device 超時
#   v2.3: PIPESTATUS 修正、patch 自動檢測、cts_log_start
# 用法: cts-verify-v2.4.sh <題目路徑> [題目路徑...]
# 範例: cts-verify-v2.4.sh domains/display/hard/Q005 domains/display/hard/Q006

LOG_FILE="/tmp/cts_verify.log"
DEVICE="${CTS_DEVICE:-27161FDH20031X}"

# ============================================
# 設備保護：腳本中斷時嘗試救回設備
# ============================================
cleanup() {
    log "腳本中斷，嘗試救回設備..."
    timeout 10 fastboot -s $DEVICE reboot 2>/dev/null || true
    timeout 10 adb -s $DEVICE reboot 2>/dev/null || true
}
trap cleanup INT TERM
SANDBOX="$HOME/develop_claw/aosp-sandbox-2"
CTS_PATH="$HOME/android-cts"
BACKUP_TOOL="$HOME/develop_claw/cts-exam-bank/tools/backup-cts-results.sh"
WEBHOOK_URL="https://discordapp.com/api/webhooks/1473692492133302322/X729Q-6zFcqrXu68SFxMBXMJJy99s9gqj3llCzeCdKMQy_vg2_JYWuSGeVIRX5Y6lol8"
WIFI_SSID="TP-LINK_5G_BA98"
WIFI_PASSWORD="2192191414"

export USE_ATS=false
export ANDROID_PRODUCT_OUT="$SANDBOX/out/target/product/panther"
export PATH="$SANDBOX/out/host/linux-x86/bin:$PATH"

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
# SKILL 整合：ccache 環境設定
# ============================================
setup_build_env() {
    log "設定編譯環境（SKILL 規範）..."
    
    # ccache 設定
    export USE_CCACHE=1
    export CCACHE_DIR="${CCACHE_DIR:-$HOME/.ccache}"
    export CCACHE_EXEC=$(which ccache)
    
    if [ -z "$CCACHE_EXEC" ]; then
        log "⚠️ 警告: ccache 未安裝"
    else
        log "✓ ccache 已啟用: $CCACHE_DIR"
    fi
    
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
# SKILL 整合：Level 1 排查（clean 單模組重試）
# ============================================
do_build() {
    local q_id="$1"
    log "[$q_id] 開始 build..."
    notify "🔨 **$q_id** 開始 build..."
    
    cd "$SANDBOX"
    source build/envsetup.sh
    lunch aosp_panther-ap2a-userdebug
    setup_build_env
    
    local start_time=$(date +%s)
    make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"
    local build_result=${PIPESTATUS[0]}
    local end_time=$(date +%s)
    local duration=$(( (end_time - start_time) / 60 ))
    
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
    make -j$(nproc) 2>&1 | tee -a "$LOG_FILE"
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

flash_device() {
    local q_id="$1"
    log "[$q_id] 開始 flash 設備 $DEVICE..."
    notify "📱 **$q_id** 開始 flash 設備..."
    
    adb -s $DEVICE reboot bootloader
    timeout 30 fastboot -s $DEVICE wait-for-device  # 等待進入 bootloader（加 timeout）
    
    fastboot -s $DEVICE flashall -w 2>&1 | tee -a "$LOG_FILE"
    local flash_result=${PIPESTATUS[0]}
    
    if [ $flash_result -ne 0 ]; then
        log "[$q_id] Flash 失敗！"
        notify "❌ **$q_id** flash 失敗！"
        return 1
    fi
    
    log "[$q_id] Flash 完成，等待設備開機..."
    notify "✅ **$q_id** flash 完成，等待設備開機..."
    
    # v2.4: fastboot reboot 加 timeout + 重試
    if ! timeout 30 fastboot -s $DEVICE reboot 2>/dev/null; then
        log "[$q_id] fastboot reboot 超時，重試..."
        sleep 3
        timeout 30 fastboot -s $DEVICE reboot 2>/dev/null || true
    fi
    
    # v2.4: adb wait-for-device 加 timeout
    if ! timeout 120 adb -s $DEVICE wait-for-device; then
        log "[$q_id] 設備卡在 bootloader，請手動重啟"
        notify "⚠️ **$q_id** 設備卡在 bootloader，請手動重啟"
        return 1
    fi
    sleep 60  # 等系統穩定
    
    log "[$q_id] 設備已就緒"
    notify "📱 **$q_id** 設備已就緒"
    
    # 設置 WiFi（CTS 需要網路連線）
    log "[$q_id] 設置 WiFi: $WIFI_SSID"
    notify "📶 **$q_id** 設置 WiFi..."
    
    sleep 10
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
        
        ./tools/cts-tradefed run cts -m CtsDisplayTestCases -t "$test_method" -s $DEVICE
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
    
    log "========== 開始驗證 $q_id =========="
    log "[$q_id] 題目目錄: $q_dir"
    notify "🔄 ========== 開始驗證 **$q_id** =========="
    
    # 讀取 meta.json 獲取 test method
    local test_method=$(cat "$q_dir/meta.json" | grep '"cts_test"' | cut -d'"' -f4)
    log "[$q_id] CTS Test: $test_method"
    
    # 還原 sandbox
    log "[$q_id] 還原 sandbox..."
    notify "🔄 **$q_id** 還原 sandbox..."
    cd "$SANDBOX"
    repo forall -c 'git checkout .' 2>/dev/null
    rm -rf out/target/
    
    # 套用 patch（自動檢測正確目錄）
    log "[$q_id] 套用 patch..."
    notify "📝 **$q_id** 套用 patch..."
    
    # 嘗試從 sandbox 根目錄 apply
    if patch --dry-run -p1 < "$q_dir/bug.patch" > /dev/null 2>&1; then
        patch -p1 < "$q_dir/bug.patch" 2>&1 | tee -a "$LOG_FILE"
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            log "[$q_id] ❌ Patch failed from sandbox root!"
            notify "❌ **$q_id** Patch 套用失敗！"
            return 1
        fi
        log "[$q_id] ✓ Patch applied from sandbox root"
    # 嘗試從 frameworks/base apply
    elif (cd frameworks/base && patch --dry-run -p1 < "$q_dir/bug.patch" > /dev/null 2>&1); then
        (cd frameworks/base && patch -p1 < "$q_dir/bug.patch") 2>&1 | tee -a "$LOG_FILE"
        if [ "${PIPESTATUS[0]}" -ne 0 ]; then
            log "[$q_id] ❌ Patch failed from frameworks/base!"
            notify "❌ **$q_id** Patch 套用失敗！"
            return 1
        fi
        log "[$q_id] ✓ Patch applied from frameworks/base"
    else
        log "[$q_id] ❌ Patch failed to apply!"
        notify "❌ **$q_id** Patch 套用失敗！"
        return 1
    fi
    
    # Build
    do_build "$q_id" || return 1
    
    # Flash
    flash_device "$q_id" || return 1
    
    # CTS
    run_cts "$q_id" "$test_method" || return 1
    
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
        # 解析 CTS 結果
        local passed=$(tail -50 "$LOG_FILE" | grep -E "^PASSED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
        local failed=$(tail -50 "$LOG_FILE" | grep -E "^FAILED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
        local total=$((passed + failed))
        
        # 使用 jq 更新（如果可用）
        if command -v jq &> /dev/null; then
            local tmp_file=$(mktemp)
            jq --arg date "$today" --argjson passed "$passed" --argjson failed "$failed" --argjson total "$total" '
                .verification_status = "complete" |
                .verification_date = $date |
                .cts_summary = {passed: $passed, failed: $failed, total: $total} |
                del(.verification_issues)
            ' "$q_dir/meta.json" > "$tmp_file" && mv "$tmp_file" "$q_dir/meta.json"
            log "[$q_id] ✓ 已更新 meta.json"
        else
            log "[$q_id] ⚠️ jq 未安裝，跳過 meta.json 更新"
        fi
    fi
    
    log "========== $q_id 驗證完成 =========="
    notify "🎉 **$q_id** 驗證完成！"
}

# ==================== 主流程 ====================

if [ $# -eq 0 ]; then
    echo "用法: $0 <題目路徑> [題目路徑...]"
    echo "範例: $0 domains/display/hard/Q005 domains/display/hard/Q006"
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
log "CTS 驗證腳本 v2.4（SKILL 整合版）"
log "題目: ${QUESTION_PATHS[*]}"
log "=========================================="
notify "🚀 開始驗證: **${QUESTION_PATHS[*]}**"

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
