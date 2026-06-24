#!/bin/bash
###
# ETL 流程模块: ODS -> DWD
# 核心架构: 配置驱动 DDL + SQL模板驱动 DML
# 流程规范:
# 1. 遍历 Table_Models/DWD/ 下的模型配置
# 2. 调用 infra 解析工具生成 ORC 建表语句并保底建表
# 3. 寻找 ETL/sql/dwd/ 下同名的 .sql 模板，注入环境变量并执行数据装载
###

###
# 有个问题，不知道为什么总共5张目标表，失败和成功的加起来往往是6张
###

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR=$(realpath "$SCRIPT_DIR/../")

# 1. 日期参数解析
[ -z "$1" ] && DATE_PARA="$(date +%F)" || DATE_PARA="$(date -d "$1" +%F)"
DO_DATE="$(date -d "$DATE_PARA -1 day" +%F)"

echo "[INFO] 业务处理分区日期 (DO_DATE): $DO_DATE"

# 2. 加载环境变量与工具库
ENV_FILE="${SCRIPT_DIR}/sql.env"
[ -f "$ENV_FILE" ] && { set -a; source "$ENV_FILE"; set +a; } || { echo "[ERROR] 缺失 sql.env"; exit 1; }
source "${PROJECT_DIR}/infra/check_sql_connect.sh"
source "${PROJECT_DIR}/infra/parse_model_utils.sh"

LOG_DIR=$(realpath "$PROJECT_DIR/log/")
[ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/ods_to_dwd_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -a "$LOG_FILE") 2>&1

DWD_DB="${HIVE_DATABASE:-mall2}"
DWD_CONF_DIR="${PROJECT_DIR}/Table_Models/DWD/$MALL_MODEL_DIR"
SQL_TEMPLATE_DIR="${PROJECT_DIR}/ETL/sql/dwd"
SUCCESS_COUNT=0
FAIL_COUNT=0

# 3. 核心单表处理逻辑
process_dwd_table() {
    local conf_file=$1
    echo "------------------------------------------"
    echo "[INFO] 开始处理 DWD 模型配置: $(basename "$conf_file")"

    # 解析目标表名
    local target_table=$(grep "^target_table" "$conf_file" | cut -d'=' -f2 | xargs)
    if [ -z "$target_table" ]; then
        echo "[ERROR] 无法从配置文件解析出 target_table！"
        return 1
    fi

    # 3.1 提取并校验依赖的上游 ODS 表是否存在
    echo "[INFO] 正在校验 ${target_table} 的上游 ODS 依赖..."
    # 使用正则从 conf 文件中抓取所有 ods_ 开头的表名并去重
    local dependent_ods_tables=$(grep -oE "ods_[a-zA-Z0-9_]+" "$conf_file" | sort | uniq)
    for ods_tbl in $dependent_ods_tables; do
        if ! check_hive_table "$DWD_DB" "$ods_tbl"; then
            echo "[ERROR] 严重阻断: 缺失依赖的上游表 ${DWD_DB}.${ods_tbl}，终止处理 $target_table！"
            return 1
        fi
    done
    echo "[INFO] 上游依赖校验全部通过。"

    # 3.2 校验下游 DWD 表是否存在以决定是否跳过 DDL
    if check_hive_table "$DWD_DB" "$target_table"; then
        echo "[INFO] 下游目标表 ${DWD_DB}.${target_table} 已存在，跳过自动建表阶段。"
    else
        
        read -p "[INPUT] 下游目标表不存在，是否创建该表？(y/n): " CREATE_CONFIRM
        
        if [[ "$CREATE_CONFIRM" == "y" || "$CREATE_CONFIRM" == "Y" ]]; then
            echo "[INFO] 下游目标表不存在，开始动态生成并执行 DDL..."
            generate_ddl_from_conf "$conf_file" "$DWD_DB" || return 1

            echo "[INFO] 生成的临时 SQL 文件路径: ${GENERATED_DDL_PATH}"
            cat "$GENERATED_DDL_PATH"

            read -p "[INPUT] 确认建表语句(y/n): " CREATE_CONFIRM
            if [[ "$CREATE_CONFIRM" == "y" || "$CREATE_CONFIRM" == "Y" ]]; then
                hive -f "$GENERATED_DDL_PATH"
                if [ $? -ne 0 ]; then
                    echo "[ERROR] 表 $target_table 创建失败！"
                    rm -f "$GENERATED_DDL_PATH"
                    return 1
                fi
                rm -f "$GENERATED_DDL_PATH"
            else
                echo "[WARN] 用户不认可建表语句。"
            fi
        else
            echo "[WARN] 用户拒绝创建表，跳过当前表的处理。"
            return 1
        fi



    fi

    # 3.3 匹配并执行 DML 模板
    local sql_file="${SQL_TEMPLATE_DIR}/${target_table}.sql"
    if [ ! -f "$sql_file" ]; then
        echo "[ERROR] 未找到对应的 SQL 模板文件: $sql_file"
        return 1
    fi

    echo "[INFO] 正在执行数据清洗与装载: $sql_file"
    # 使用 hiveconf 传递变量给 SQL 模板
    hive -hiveconf app_db="$DWD_DB" -hiveconf do_date="$DO_DATE" -f "$sql_file"
    
    if [ $? -ne 0 ]; then
        echo "[ERROR] DML 装载失败: $target_table"
        return 1
    fi
    echo "[SUCCESS] 表 $target_table 处理完成！"
}

# 4. 主流程编排
echo "[INFO] 开始扫描并处理 DWD 层模型配置..."
for conf_file in $(find "$DWD_CONF_DIR" -name "*.conf"); do
    process_dwd_table "$conf_file"
    [ $? -eq 0 ] && ((SUCCESS_COUNT++)) || ((FAIL_COUNT++))
done

echo "=========================================="
echo "  DWD 层任务执行完毕！"
echo "  处理分区: $DO_DATE"
echo "  成功: ${SUCCESS_COUNT} 个"
echo "  失败: ${FAIL_COUNT} 个"
echo "=========================================="
[ "$FAIL_COUNT" -gt 0 ] && exit 1 || exit 0