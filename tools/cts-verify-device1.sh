#!/bin/bash
# CTS 題目驗證腳本 v2.1 — 整合 AOSP Skill 規範
# 用法: cts-verify-v2.1.sh <題目路徑> [題目路徑...]
# 範例: cts-verify-v2.1.sh domains/display/hard/Q005 domains/display/hard/Q006

LOG_FILE="/tmp/cts_verify.log"
DEVICE="27161FDH20031X"
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
    local build_result=$?
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
    build_result=$?
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
    sleep 5
    
    fastboot flashall -w 2>&1 | tee -a "$LOG_FILE"
    local flash_result=$?
    
    if [ $flash_result -ne 0 ]; then
        log "[$q_id] Flash 失敗！"
        notify "❌ **$q_id** flash 失敗！"
        return 1
    fi
    
    log "[$q_id] Flash 完成，等待設備開機..."
    notify "✅ **$q_id** flash 完成，等待設備開機..."
    
    adb -s $DEVICE wait-for-device
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
    
    (
        unset ANDROID_BUILD_TOP ANDROID_HOST_OUT ANDROID_PRODUCT_OUT OUT_DIR TARGET_PRODUCT TARGET_BUILD_VARIANT
        cd "$CTS_PATH"
        
        if [ ! -f "./tools/cts-tradefed" ]; then
            echo "[$q_id] 錯誤：找不到 cts-tradefed！"
            exit 1
        fi
        
        ./tools/cts-tradefed run cts -m CtsDisplayTestCases -t "$test_method" -s $DEVICE
    ) 2>&1 | tee -a "$LOG_FILE"
    
    if grep -q "ClassNotFoundException\|Could not find or load main class" "$LOG_FILE"; then
        log "[$q_id] CTS 執行失敗：Java class 載入錯誤"
        notify "❌ **$q_id** CTS 執行失敗：Java class 載入錯誤"
        return 1
    fi
    
    # 解析 CTS 結果（支援大寫 PASSED/FAILED 格式）
    local passed=$(tail -50 "$LOG_FILE" | grep -E "^PASSED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
    local failed=$(tail -50 "$LOG_FILE" | grep -E "^FAILED\s*:" | grep -oP ':\s*\K\d+' || echo "0")
    
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
    
    # 套用 patch
    log "[$q_id] 套用 patch..."
    notify "📝 **$q_id** 套用 patch..."
    patch -p1 < "$q_dir/bug.patch" 2>&1 | tee -a "$LOG_FILE"
    
    # Build
    do_build "$q_id" || return 1
    
    # Flash
    flash_device "$q_id" || return 1
    
    # CTS
    run_cts "$q_id" "$test_method" || return 1
    
    # 備份
    log "[$q_id] 備份 CTS 結果..."
    $BACKUP_TOOL "$q_dir" 2>&1 | tee -a "$LOG_FILE"
    
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
log "CTS 驗證腳本 v2.1（SKILL 整合版）"
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
