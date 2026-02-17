#!/bin/bash
# =============================================================================
# backup-cts-results.sh - CTS 測試結果備份工具
# =============================================================================
# 版本: v1.0.0
# 更新: 2026-02-17
#
# 用途: 將 CTS 測試結果完整備份到題目目錄
#
# 使用方式:
#   ./backup-cts-results.sh <domain> <difficulty> <question_id> [result_dir]
#
# 範例:
#   ./backup-cts-results.sh display medium Q005
#   ./backup-cts-results.sh display hard Q001 2026.02.17_17.18.40.043_3970
#
# =============================================================================

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 預設路徑
CTS_RESULTS_BASE="${CTS_RESULTS_BASE:-$HOME/android-cts/results}"
EXAM_BANK_BASE="${EXAM_BANK_BASE:-$HOME/develop_claw/cts-exam-bank}"

# 函數：顯示使用說明
usage() {
    echo "用法: $0 <domain> <difficulty> <question_id> [result_dir]"
    echo ""
    echo "參數:"
    echo "  domain       領域名稱 (例: display, camera, media)"
    echo "  difficulty   難度 (easy, medium, hard)"
    echo "  question_id  題目編號 (例: Q001, Q005)"
    echo "  result_dir   CTS 結果目錄名稱 (可選，預設使用 latest)"
    echo ""
    echo "範例:"
    echo "  $0 display medium Q005"
    echo "  $0 display hard Q001 2026.02.17_17.18.40.043_3970"
    echo ""
    echo "環境變數:"
    echo "  CTS_RESULTS_BASE  CTS 結果根目錄 (預設: ~/android-cts/results)"
    echo "  EXAM_BANK_BASE    題庫根目錄 (預設: ~/develop_claw/cts-exam-bank)"
    exit 1
}

# 函數：列出可用的 CTS 結果
list_results() {
    echo -e "${BLUE}可用的 CTS 測試結果:${NC}"
    echo "---"
    ls -la "$CTS_RESULTS_BASE" | grep -E "^d|^l" | grep -v "^\." | tail -n +2
    echo "---"
}

# 檢查參數
if [ $# -lt 3 ]; then
    usage
fi

DOMAIN="$1"
DIFFICULTY="$2"
QUESTION_ID="$3"
RESULT_DIR="${4:-latest}"

# 驗證難度
if [[ ! "$DIFFICULTY" =~ ^(easy|medium|hard)$ ]]; then
    echo -e "${RED}錯誤: 難度必須是 easy, medium, 或 hard${NC}"
    exit 1
fi

# 構建路徑
QUESTION_PATH="$EXAM_BANK_BASE/domains/$DOMAIN/$DIFFICULTY/$QUESTION_ID"
SOURCE_PATH="$CTS_RESULTS_BASE/$RESULT_DIR"
DEST_PATH="$QUESTION_PATH/cts_results"

# 檢查題目目錄是否存在
if [ ! -d "$QUESTION_PATH" ]; then
    echo -e "${RED}錯誤: 題目目錄不存在: $QUESTION_PATH${NC}"
    echo ""
    echo "可用的題目目錄:"
    ls "$EXAM_BANK_BASE/domains/$DOMAIN/$DIFFICULTY/" 2>/dev/null || echo "  (無)"
    exit 1
fi

# 檢查 CTS 結果目錄是否存在
if [ ! -d "$SOURCE_PATH" ]; then
    echo -e "${RED}錯誤: CTS 結果目錄不存在: $SOURCE_PATH${NC}"
    echo ""
    list_results
    exit 1
fi

# 如果使用 latest，解析實際目錄名稱
if [ "$RESULT_DIR" = "latest" ]; then
    ACTUAL_RESULT_DIR=$(readlink -f "$SOURCE_PATH")
    RESULT_DIR_NAME=$(basename "$ACTUAL_RESULT_DIR")
else
    RESULT_DIR_NAME="$RESULT_DIR"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}CTS 測試結果備份工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "題目: ${GREEN}$DOMAIN/$DIFFICULTY/$QUESTION_ID${NC}"
echo -e "來源: ${YELLOW}$SOURCE_PATH${NC}"
echo -e "目標: ${YELLOW}$DEST_PATH${NC}"
echo -e "結果目錄: ${YELLOW}$RESULT_DIR_NAME${NC}"
echo ""

# 如果目標目錄已存在，詢問是否覆蓋
if [ -d "$DEST_PATH" ]; then
    echo -e "${YELLOW}警告: 目標目錄已存在${NC}"
    read -p "是否覆蓋? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "取消操作"
        exit 0
    fi
    rm -rf "$DEST_PATH"
fi

# 建立目標目錄
mkdir -p "$DEST_PATH"

# 複製所有檔案
echo -e "${BLUE}正在複製檔案...${NC}"

# 核心結果檔案
CORE_FILES=(
    "test_result.xml"
    "test_result.html"
    "test_result.pb"
    "test_result_failures_suite.html"
    "invocation_summary.txt"
    "checksum-suite.data"
    "test-report.properties"
    "compatibility_result.css"
    "compatibility_result.xsl"
    "logo.png"
)

for file in "${CORE_FILES[@]}"; do
    if [ -f "$SOURCE_PATH/$file" ]; then
        cp "$SOURCE_PATH/$file" "$DEST_PATH/"
        echo "  ✓ $file"
    fi
done

# 複製目錄
DIRS=(
    "config"
    "device-info-files"
    "module_reports"
    "proto"
    "report-log-files"
    "vintf-files"
)

for dir in "${DIRS[@]}"; do
    if [ -d "$SOURCE_PATH/$dir" ]; then
        cp -r "$SOURCE_PATH/$dir" "$DEST_PATH/"
        echo "  ✓ $dir/"
    fi
done

# 建立 metadata 檔案
METADATA_FILE="$DEST_PATH/backup_metadata.json"
cat > "$METADATA_FILE" << EOF
{
  "backup_time": "$(date -Iseconds)",
  "source_dir": "$RESULT_DIR_NAME",
  "question": {
    "domain": "$DOMAIN",
    "difficulty": "$DIFFICULTY",
    "id": "$QUESTION_ID"
  },
  "files_copied": $(ls -1 "$DEST_PATH" | wc -l),
  "total_size": "$(du -sh "$DEST_PATH" | cut -f1)"
}
EOF
echo "  ✓ backup_metadata.json (備份資訊)"

# 統計
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}備份完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "檔案統計:"
echo "  - 檔案數量: $(find "$DEST_PATH" -type f | wc -l)"
echo "  - 總大小: $(du -sh "$DEST_PATH" | cut -f1)"
echo ""
echo -e "備份位置: ${GREEN}$DEST_PATH${NC}"
