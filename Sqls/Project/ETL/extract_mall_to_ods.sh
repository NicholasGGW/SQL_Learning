#!/bin/bash
###
# 此脚本用作ETL流程的E模块，负责将上游的mysql的mall数据库内容抽取转化至hdfs，并可以通过hive进行读取编辑，用作OLAP系统的ods层

# 1.支持输入日期参数进行写入到对应的前一天的分区
# 2.默认覆盖更新对应的分区，是否需要后续设计增量更新？
# 3.


#基础逻辑
#需要判断原、目标连接库和表是否存在，然后执行对应命令
#若目标表不存在，需要创建，通过原表的字段自动读取并转换为目标表的字段和类型

###



# ================= 1. 获取脚本绝对路径和入参 =================
# 无论在哪个目录执行该脚本，都能正确找到同目录下的文件
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "当前文件目录为 $SCRIPT_DIR"
PROJECT_DIR=$(realpath "$SCRIPT_DIR/../")
echo "当前项目目录为 $PROJECT_DIR"
[ -z "$1" ] && DATE_PARA="$(date +%F)" || DATE_PARA="$(date -d "$1" +%F)"
echo "当前入参为 $1"
echo "当前取DATE为 $DATE_PARA"
DAY_BEFORE_DATE_PARA="$(date -d "$DATE_PARA -1 day" +%F)"
echo "DATE前一天为 $DAY_BEFORE_DATE_PARA"

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

# ================= 5. 核心封装函数 =================

# 5.1 全局前置检查（只执行一次）
global_pre_check() {
    echo "[INFO] 正在进行全局前置检查..."
    check_mysql_conn "$MYSQL_JDBC" "$MYSQL_USER" "$MYSQL_PASS" || {
        echo "[ERROR] 全局 MySQL 连接失败，终止所有任务！"
        exit 1
    }
}

# 5.2 单表处理流水线（核心逻辑）
# 参数: $1=配置文件路径
process_single_table() {
    local upstream_conf_path=$1
    local table_name=$(basename "$upstream_conf_path" .conf)

    echo "------------------------------------------"
    echo "[INFO] 开始处理表: ${table_name}"

    # 1. 解析配置
    parse_upstream_config "$upstream_conf_path" || return 1
    # Bash 内置的字符串替换语法。它会在 $upstream_conf_path 变量中查找 Upstream 并替换为 ODS。
    local ods_conf_path=${upstream_conf_path/Upstream/ODS}

    # 检查推导出的 ODS 配置文件是否存在
    if [ ! -f "$ods_conf_path" ]; then
        echo "[WARN] 未找到对应的 ODS 配置文件: $ods_conf_path"
        echo "[INFO] 将使用默认配置（不分区、非维表）继续执行..."
        # 这里可以选择跳过，或者使用默认值继续
    else
        echo "[INFO] 正在解析 ODS 配置: $ods_conf_path"
        # 解析下游 ODS 配置
        parse_ods_config  "$ods_conf_path" || return 1
    fi

    # 2. 校验上游源表
    check_mysql_table "$MYSQL_JDBC" "$MYSQL_USER" "$MYSQL_PASS" "$UP_TABLE_NAME" || return 1

    # 3. 校验下游 Hive 表是否存在，确认是否建表
    echo "[INFO] 检查 Hive 表 [${ODS_DB_NAME}.${ODS_TABLE_NAME}] 是否存在..."
    # 假设 check_hive_table 函数返回 0 表示存在，1 表示不存在
    if ! check_hive_table "$ODS_DB_NAME" "$ODS_TABLE_NAME"; then
        
        echo "[WARN] 下游 Hive 表不存在！"
        read -p "[INPUT] 是否立即根据上游元数据自动创建该表？(y/n): " CREATE_CONFIRM
        
        if [[ "$CREATE_CONFIRM" == "y" || "$CREATE_CONFIRM" == "Y" ]]; then
            echo "[INFO] 正在实时获取 MySQL 元数据并生成 Hive DDL..."
            #虽然source了调用的子脚本，但是它的全局变量的改动总是传不过来
            # 调用动态建表函数，不能用()包起来！()是子进程，全局变量的改动无法体现
            generate_hive_ddl_from_mysql \
                "$UP_TABLE_NAME" "$ODS_DB_NAME" "$ODS_TABLE_NAME"
            if [ $? -ne 0 ]; then
                echo "[ERROR] 生成 Hive DDL 失败，终止执行。"
                return 1
            fi
            
            echo "[INFO] 生成的临时 SQL 文件路径: ${GENERATED_SQL_PATH}"
            cat "$GENERATED_SQL_PATH"

            read -p "[INPUT] 确认建表语句(y/n): " CREATE_CONFIRM
            if [[ "$CREATE_CONFIRM" == "y" || "$CREATE_CONFIRM" == "Y" ]]; then
                echo "[INFO] 正在执行 Hive 建表..."
                
                # 执行建表
                hive -f "${GENERATED_SQL_PATH}"
                HIVE_STATUS=$?
                #顺手删临时文件
                if [ -f "${GENERATED_SQL_PATH}" ]; then
                    rm -f "${GENERATED_SQL_PATH}"
                fi

                #判断执行结果
                if [ $HIVE_STATUS -ne 0 ]; then
                    echo "[ERROR] Hive 表 ${ODS_TABLE_NAME} 创建失败！"
                    exit 1
                else
                    echo "[SUCCESS] Hive 表 ${ODS_TABLE_NAME} 创建成功！"
                fi
                
            else
                echo "[WARN] 用户不认可建表语句。"
            fi
        else
            echo "[WARN] 用户拒绝创建表，跳过当前表的处理。"
            return 1
        fi
    else
        echo "[INFO] 下游 Hive 表已存在，准备进行数据同步..."
    fi

    # 4. 执行 Sqoop 数据抽取
    echo "[INFO] 开始 Sqoop 导入: ${UP_TABLE_NAME} -> ${ODS_DB_NAME}.${ODS_TABLE_NAME}"
    #        --table "$UP_TABLE_NAME" \
    # 默认使用 dt 作为分区字段，如果配置了其他字段则使用配置的字段
    local p_col="${PARTITION_COL:-dt}"
    local p_val="${DAY_BEFORE_DATE_PARA}"
    sqoop import \
        --connect "$MYSQL_JDBC" \
        --username "$MYSQL_USER" \
        --password "$MYSQL_PASS" \
        --hive-import \
        --hive-database "$ODS_DB_NAME" \
        --hive-table "$ODS_TABLE_NAME" \
        --hive-partition-key "$p_col" \
        --hive-partition-value "$p_val" \
        --hive-overwrite \
        --fields-terminated-by '\t' \
        --null-string '\\N' \
        --null-non-string '\\N' \
        --target-dir "/test/$ODS_DB_NAME/$ODS_TABLE_NAME" \
        --delete-target-dir \
        --query "select * from $UP_TABLE_NAME WHERE \$CONDITIONS" \
        --split-by id \
        --num-mappers 4 || { echo "[ERROR] Sqoop 导入失败: $UP_TABLE_NAME"; return 1; } 
    echo "[SUCCESS] 表 ${table_name} 处理完成！"
}

# ================= 6. 主流程编排 =================

# 6.1 执行全局检查
global_pre_check

# 6.2 遍历配置目录，自动发现所有表
UPSTREAM_DB_DIR="${PROJECT_DIR}/Table_Models/Upstream/mall_db"
SUCCESS_COUNT=0
FAIL_COUNT=0
echo "处理 ${UPSTREAM_DB_DIR} 的上游表"

conf_files=("${UPSTREAM_DB_DIR}"/*.conf)
echo "[DEBUG] 找到的配置文件数量: ${#conf_files[@]}"
#echo "[DEBUG] 文件路径列表:"
#printf "  - %s\n" "${conf_files[@]}"

# 3. 遍历数组进行处理
for conf_file in "${conf_files[@]}"; do
#for conf_file in "${UPSTREAM_DB_DIR}"/*.conf; do
    echo "处理 ${conf_file}"
    # 防止目录下没有 .conf 文件时 glob 表达式原样传入
    [ -f "$conf_file" ] || continue

    # 调用单表处理函数
    process_single_table "$conf_file"

    # 记录成功/失败状态 (函数内部 return 1 时，这里 $? 为 1)
    if [ $? -eq 0 ]; then
        ((SUCCESS_COUNT++))
    else
        ((FAIL_COUNT++))
    fi
done

# 6.3 输出最终执行摘要
echo "=========================================="
echo "  任务执行完毕！"
echo "  成功: ${SUCCESS_COUNT} 个表"
echo "  失败: ${FAIL_COUNT} 个表"
echo "=========================================="

# 如果有失败的表，以非 0 状态码退出，方便对接外部调度系统(如 DolphinScheduler/Airflow)
[ "$FAIL_COUNT" -gt 0 ] && exit 1 || exit 0