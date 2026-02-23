#!/bin/bash
# CTS 题目完整性检查工具 v1.1
# 用法: check-question-completeness.sh [--update] [题目路径|领域] [难度]
# 范例: 
#   check-question-completeness.sh domains/display/medium/Q001
#   check-question-completeness.sh display medium
#   check-question-completeness.sh display          # 检查 display 所有难度
#   check-question-completeness.sh                  # 检查所有题目
#   check-question-completeness.sh --update display # 检查并更新 meta.json

REPO_ROOT="$HOME/develop_claw/cts-exam-bank"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 选项
UPDATE_META=true  # 默认总是更新 meta.json

# 统计变量
TOTAL=0
COMPLETE=0
INCOMPLETE=0
MISSING_FILES=0
MISSING_CTS=0
MISSING_LOGS=0
BUG_INEFFECTIVE=0

update_meta_json() {
    local q_path="$1"
    local status="$2"
    local issues_json="$3"
    local passed="$4"
    local failed="$5"
    local total_tests="$6"
    
    local meta_file="$q_path/meta.json"
    [ ! -f "$meta_file" ] && return
    
    local today=$(date +%Y-%m-%d)
    
    # 使用 python3 更新 JSON（更可靠）
    python3 << EOF
import json
import sys

try:
    with open('$meta_file', 'r') as f:
        data = json.load(f)
    
    # verification_status 只由 cts-verify-*.sh 設置，這裡不碰
    data['completeness_status'] = '$status'
    data['completeness_date'] = '$today'
    data['completeness_issues'] = $issues_json
    data['cts_summary'] = {
        'passed': ${passed:-0},
        'failed': ${failed:-0},
        'total': ${total_tests:-0}
    }
    
    with open('$meta_file', 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
except Exception as e:
    print(f"Error updating meta.json: {e}", file=sys.stderr)
    sys.exit(1)
EOF
}

check_question() {
    local q_path="$1"
    local qid=$(basename "$q_path")
    local issues=()
    local passed=0
    local failed=0
    local total_tests=0
    
    ((TOTAL++))
    
    # 1. 检查必要文件
    local files_ok=true
    for f in question.md answer.md bug.patch meta.json; do
        if [ ! -f "$q_path/$f" ]; then
            issues+=("缺少 $f")
            files_ok=false
        fi
    done
    [ "$files_ok" = false ] && ((MISSING_FILES++))
    
    # 2. 检查 CTS 结果
    if [ ! -f "$q_path/cts_results/test_result.xml" ]; then
        issues+=("无 CTS 结果")
        ((MISSING_CTS++))
    else
        # 读取 CTS 统计
        if [ -f "$q_path/cts_results/invocation_summary.txt" ]; then
            passed=$(grep -oP 'PASSED\s*:\s*\K\d+' "$q_path/cts_results/invocation_summary.txt" 2>/dev/null | head -1)
            failed=$(grep -oP 'FAILED\s*:\s*\K\d+' "$q_path/cts_results/invocation_summary.txt" 2>/dev/null | head -1)
            total_tests=$(grep -oP 'Total Tests\s*:\s*\K\d+' "$q_path/cts_results/invocation_summary.txt" 2>/dev/null | head -1)
            passed=${passed:-0}
            failed=${failed:-0}
            total_tests=${total_tests:-0}
        fi
        
        # 3. 检查 logs
        if [ ! -d "$q_path/cts_results/logs" ] || [ -z "$(ls -A "$q_path/cts_results/logs" 2>/dev/null)" ]; then
            issues+=("缺少 logs")
            ((MISSING_LOGS++))
        fi
        
        # 4. 检查 bug 是否有效 (FAILED > 0)
        if [ "$failed" -eq 0 ]; then
            issues+=("Bug 无效 (FAILED=0)")
            ((BUG_INEFFECTIVE++))
        fi
    fi
    
    # 输出结果
    local rel_path="${q_path#$REPO_ROOT/}"
    if [ ${#issues[@]} -eq 0 ]; then
        echo -e "${GREEN}✅${NC} $rel_path (PASSED:$passed FAILED:$failed)"
        ((COMPLETE++))
        
        # 更新 meta.json
        if [ "$UPDATE_META" = true ]; then
            update_meta_json "$q_path" "complete" "[]" "$passed" "$failed" "$total_tests"
            echo -e "   ${YELLOW}→${NC} meta.json 已更新"
        fi
    else
        echo -e "${RED}❌${NC} $rel_path"
        for issue in "${issues[@]}"; do
            echo -e "   ${YELLOW}→${NC} $issue"
        done
        ((INCOMPLETE++))
        
        # 更新 meta.json
        if [ "$UPDATE_META" = true ] && [ -f "$q_path/meta.json" ]; then
            # 构建 issues JSON 数组
            local issues_json="["
            local first=true
            for issue in "${issues[@]}"; do
                if [ "$first" = true ]; then
                    issues_json+="\"$issue\""
                    first=false
                else
                    issues_json+=",\"$issue\""
                fi
            done
            issues_json+="]"
            
            update_meta_json "$q_path" "incomplete" "$issues_json" "$passed" "$failed" "$total_tests"
            echo -e "   ${YELLOW}→${NC} meta.json 已更新"
        fi
    fi
}

scan_questions() {
    local domain="$1"
    local difficulty="$2"
    
    if [ -n "$difficulty" ]; then
        # 扫描特定难度
        local dir="$REPO_ROOT/domains/$domain/$difficulty"
        if [ -d "$dir" ]; then
            echo ""
            echo "=== $domain / $difficulty ==="
            for q in "$dir"/Q*/; do
                [ -d "$q" ] && check_question "$q"
            done
        fi
    else
        # 扫描所有难度
        for diff in easy medium hard; do
            local dir="$REPO_ROOT/domains/$domain/$diff"
            if [ -d "$dir" ]; then
                echo ""
                echo "=== $domain / $diff ==="
                for q in "$dir"/Q*/; do
                    [ -d "$q" ] && check_question "$q"
                done
            fi
        done
    fi
}

print_summary() {
    echo ""
    echo "=========================================="
    echo "              检查结果汇总"
    echo "=========================================="
    echo -e "总计检查:     $TOTAL 题"
    echo -e "${GREEN}完整:         $COMPLETE 题${NC}"
    if [ $INCOMPLETE -gt 0 ]; then
        echo -e "${RED}不完整:       $INCOMPLETE 题${NC}"
        echo ""
        echo "问题分类:"
        [ $MISSING_FILES -gt 0 ] && echo -e "  ${YELLOW}→${NC} 缺少必要文件: $MISSING_FILES"
        [ $MISSING_CTS -gt 0 ] && echo -e "  ${YELLOW}→${NC} 无 CTS 结果:   $MISSING_CTS"
        [ $MISSING_LOGS -gt 0 ] && echo -e "  ${YELLOW}→${NC} 缺少 logs:     $MISSING_LOGS"
        [ $BUG_INEFFECTIVE -gt 0 ] && echo -e "  ${YELLOW}→${NC} Bug 无效:      $BUG_INEFFECTIVE"
    fi
    [ "$UPDATE_META" = true ] && echo -e "\n${GREEN}meta.json 已同步更新${NC}"
    echo "=========================================="
}

print_usage() {
    echo "用法: $0 [--no-update] [题目路径|领域] [难度]"
    echo ""
    echo "选项:"
    echo "  --no-update   检查但不更新 meta.json（默认会更新）"
    echo ""
    echo "范例:"
    echo "  $0 display medium          # 检查 display/medium 并更新 meta.json"
    echo "  $0 --no-update display     # 只检查，不更新"
    echo "  $0                         # 检查所有题目并更新 meta.json"
}

# 解析参数
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-update)
            UPDATE_META=false
            shift
            ;;
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# 主逻辑
echo "CTS 题目完整性检查工具 v1.2"
[ "$UPDATE_META" = false ] && echo "(--no-update 模式：不更新 meta.json)"
echo ""

if [ ${#ARGS[@]} -eq 0 ]; then
    # 检查所有领域
    for domain_dir in "$REPO_ROOT"/domains/*/; do
        domain=$(basename "$domain_dir")
        scan_questions "$domain"
    done
elif [ -d "${ARGS[0]}" ]; then
    # 直接指定题目路径
    check_question "${ARGS[0]}"
elif [ -d "$REPO_ROOT/domains/${ARGS[0]}" ]; then
    # 指定领域
    scan_questions "${ARGS[0]}" "${ARGS[1]}"
else
    echo "错误: 找不到 ${ARGS[0]}"
    print_usage
    exit 1
fi

print_summary
