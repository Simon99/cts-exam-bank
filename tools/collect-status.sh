#!/bin/bash
# CTS 題目驗證狀態收集工具 v1.0
# 用法: collect-status.sh [領域] [難度]
# 範例:
#   collect-status.sh              # 所有領域
#   collect-status.sh display      # display 所有難度
#   collect-status.sh display hard # display hard 難度
# 
# 注意：此工具只讀取統計，不修改任何檔案

REPO_ROOT="$HOME/develop_claw/cts-exam-bank"

# 顏色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 參數
DOMAIN="${1:-}"
DIFFICULTY="${2:-}"

# 統計
declare -A STATS

get_verified_status() {
    local meta_file="$1"
    
    if [ ! -f "$meta_file" ]; then
        echo "no_meta"
        return
    fi
    
    # 優先讀 "verified": true/false，其次讀 "verification_status"
    local verified=$(python3 -c "
import json
try:
    with open('$meta_file', 'r') as f:
        data = json.load(f)
    # 優先檢查 verified 欄位
    if 'verified' in data:
        if isinstance(data['verified'], bool):
            print('verified' if data['verified'] else 'not_verified')
        elif isinstance(data['verified'], dict):
            # verified: { status: ..., date: ... }
            print('verified' if data['verified'].get('status') else 'not_verified')
        else:
            print('not_verified')
    elif 'verification_status' in data:
        status = data['verification_status']
        if status == 'verified':
            print('verified')
        elif status == 'pending':
            print('pending')
        elif status == 'incomplete':
            print('incomplete')
        elif status == 'test_class_not_found':
            print('test_class_not_found')
        else:
            print('unknown:' + str(status))
    else:
        print('no_status')
except Exception as e:
    print('error')
" 2>/dev/null)
    
    echo "$verified"
}

scan_questions() {
    local domain="$1"
    local diff="$2"
    local pattern
    
    if [ -n "$domain" ] && [ -n "$diff" ]; then
        pattern="$REPO_ROOT/domains/$domain/$diff/Q*"
    elif [ -n "$domain" ]; then
        pattern="$REPO_ROOT/domains/$domain/*/Q*"
    else
        pattern="$REPO_ROOT/domains/*/*/Q*"
    fi
    
    for q_dir in $pattern; do
        [ ! -d "$q_dir" ] && continue
        
        local meta_file="$q_dir/meta.json"
        local status=$(get_verified_status "$meta_file")
        local rel_path="${q_dir#$REPO_ROOT/}"
        
        # 解析領域和難度
        local d=$(echo "$rel_path" | cut -d'/' -f2)
        local diff_level=$(echo "$rel_path" | cut -d'/' -f3)
        local q_id=$(echo "$rel_path" | cut -d'/' -f4)
        
        # 累加統計
        local key="${d}/${diff_level}"
        STATS["${key}_total"]=$((${STATS["${key}_total"]:-0} + 1))
        STATS["${key}_${status}"]=$((${STATS["${key}_${status}"]:-0} + 1))
        
        # 輸出詳情（如果指定了難度）
        if [ -n "$DIFFICULTY" ]; then
            case "$status" in
                verified) echo -e "  ${GREEN}✅${NC} $q_id" ;;
                not_verified) echo -e "  ${RED}❌${NC} $q_id (not verified)" ;;
                pending) echo -e "  ${YELLOW}⏳${NC} $q_id (pending)" ;;
                incomplete) echo -e "  ${YELLOW}⚠️${NC} $q_id (incomplete)" ;;
                test_class_not_found) echo -e "  ${RED}🚫${NC} $q_id (test class not found)" ;;
                *) echo -e "  ${CYAN}?${NC} $q_id ($status)" ;;
            esac
        fi
    done
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "          驗證狀態統計"
    echo "=========================================="
    echo ""
    
    # 收集所有 domain/difficulty 組合
    declare -A domains
    for key in "${!STATS[@]}"; do
        local base="${key%_*}"
        if [[ "$key" == *"_total" ]]; then
            domains["$base"]=1
        fi
    done
    
    # 總計
    local grand_total=0
    local grand_verified=0
    
    # 按領域分組輸出
    local current_domain=""
    for key in $(echo "${!domains[@]}" | tr ' ' '\n' | sort); do
        local d=$(echo "$key" | cut -d'/' -f1)
        local diff=$(echo "$key" | cut -d'/' -f2)
        
        if [ "$d" != "$current_domain" ]; then
            [ -n "$current_domain" ] && echo ""
            echo -e "${CYAN}【$d】${NC}"
            current_domain="$d"
        fi
        
        local total=${STATS["${key}_total"]:-0}
        local verified=${STATS["${key}_verified"]:-0}
        local not_verified=${STATS["${key}_not_verified"]:-0}
        local pending=${STATS["${key}_pending"]:-0}
        local incomplete=${STATS["${key}_incomplete"]:-0}
        local tcnf=${STATS["${key}_test_class_not_found"]:-0}
        
        grand_total=$((grand_total + total))
        grand_verified=$((grand_verified + verified))
        
        printf "  %-8s: ${GREEN}%2d${NC}/%2d verified" "$diff" "$verified" "$total"
        
        # 顯示其他狀態
        local others=""
        [ "$not_verified" -gt 0 ] && others+=" ❌${not_verified}"
        [ "$pending" -gt 0 ] && others+=" ⏳${pending}"
        [ "$incomplete" -gt 0 ] && others+=" ⚠️${incomplete}"
        [ "$tcnf" -gt 0 ] && others+=" 🚫${tcnf}"
        [ -n "$others" ] && printf " (%s)" "$others"
        echo ""
    done
    
    echo ""
    echo "=========================================="
    printf "總計: ${GREEN}%d${NC}/%d 已驗證 (%.0f%%)\n" "$grand_verified" "$grand_total" "$(echo "scale=0; $grand_verified * 100 / $grand_total" | bc 2>/dev/null || echo 0)"
    echo "=========================================="
}

# JSON 輸出模式
print_json() {
    echo "{"
    local first=true
    
    declare -A domains
    for key in "${!STATS[@]}"; do
        local base="${key%_*}"
        if [[ "$key" == *"_total" ]]; then
            domains["$base"]=1
        fi
    done
    
    for key in $(echo "${!domains[@]}" | tr ' ' '\n' | sort); do
        [ "$first" = false ] && echo ","
        first=false
        
        local total=${STATS["${key}_total"]:-0}
        local verified=${STATS["${key}_verified"]:-0}
        local not_verified=${STATS["${key}_not_verified"]:-0}
        local pending=${STATS["${key}_pending"]:-0}
        local incomplete=${STATS["${key}_incomplete"]:-0}
        local tcnf=${STATS["${key}_test_class_not_found"]:-0}
        
        printf '  "%s": {"total": %d, "verified": %d, "not_verified": %d, "pending": %d, "incomplete": %d, "test_class_not_found": %d}' \
            "$key" "$total" "$verified" "$not_verified" "$pending" "$incomplete" "$tcnf"
    done
    
    echo ""
    echo "}"
}

# 主程式
cd "$REPO_ROOT" || exit 1

if [ "$1" = "--json" ]; then
    shift
    DOMAIN="${1:-}"
    DIFFICULTY="${2:-}"
    scan_questions "$DOMAIN" "$DIFFICULTY"
    print_json
else
    [ -n "$DIFFICULTY" ] && echo -e "${CYAN}【$DOMAIN / $DIFFICULTY】${NC}"
    scan_questions "$DOMAIN" "$DIFFICULTY"
    print_summary
fi
