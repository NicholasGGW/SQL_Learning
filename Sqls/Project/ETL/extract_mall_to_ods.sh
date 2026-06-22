#!/bin/bash
###
# 此脚本用作ETL流程的E模块，负责将上游的mysql的mall数据库内容抽取转化至hdfs，并可以通过hive进行读取编辑，用作OLAP系统的ods层

# 1.支持输入-all参数进行全量同步
# 2.默认增量更新，使用-force参数用于全量更新
# 3.


#基础逻辑
#需要判断原、目标连接库和表是否存在，然后执行对应命令
###



# ================= 1. 获取脚本绝对路径 =================
# 无论在哪个目录执行该脚本，都能正确找到同目录下的文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "当前文件目录为 $SCRIPT_DIR"
PROJECT_DIR=$(realpath "$SCRIPT_DIR/../")
echo "当前项目目录为 $PROJECT_DIR"

# ================= 2. 加载 .env 环境变量 =================
ENV_FILE="${SCRIPT_DIR}/sql.env"
if [ -f "$ENV_FILE" ]; then
    # set -a 会自动 export 所有后续赋值的变量，source 后再 set +a 关闭
    set -a
    source "$ENV_FILE"
    set +a
    echo "[INFO] 成功加载配置文件: $ENV_FILE"
else
    echo "[ERROR] 配置文件 $ENV_FILE 不存在！"
    exit 1
fi

# ================= 3. 引入公共操作层 =================
source "${PROJECT_DIR}/infra/check_sql_connect.sh"
source "${PROJECT_DIR}/infra/parse_model_utils.sh"


# ================= 4. 设置全局日志重定向 =================
LOG_DIR=$(realpath "$PROJECT_DIR/log/")
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
fi
LOG_FILE="${LOG_DIR}/sqoop_import_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=========================================="
echo "  日志文件写入: $LOG_FILE"
echo "=========================================="

# ================= 5. 获取上游表及ODS表列表并检查 =================
# 5.1 检查上游表mysql链接
check_mysql_conn "$MYSQL_JDBC" "$MYSQL_USER" "$MYSQL_PASS" || exit 1

# 5.2 获取上游表mysql表列表、解析建模文件、检查表存在性
TABLE_LIST=("user_info" "order_master")
DB_DIR="${PROJECT_DIR}/Table_Models/Upstream/mall_db"

for table_conf in "${TABLE_LIST[@]}"; do
    CONF_PATH="${DB_DIR}/${table_conf}.conf"

    # 1. 解析配置
    parse_table_config "$CONF_PATH"

    echo "==========================================" | tee -a "$LOG_FILE"
    echo "开始处理表: ${TABLE_NAME}" | tee -a "$LOG_FILE"
    check_mysql_table "$MYSQL_JDBC" "$MYSQL_USER" "$MYSQL_PASS" "$TABLE_NAME" || exit 1
done
#check_hive_table "$HIVE_DB" "$HIVE_TABLE"

# ================= 6. 交互式确认 =================
echo ""
read -p "前置检查已完成，是否继续执行数据导入？(y/n): " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "[INFO] 用户取消操作，脚本退出。"
    exit 0
fi