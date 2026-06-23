#!/bin/bash

# 函数: parse_upstream_config、parse_ods_config
# 作用: 解析指定的 .conf 配置文件，提取配置项并导出为全局环境变量
# 参数: $1 = 配置文件的绝对路径

# 1. 解析上游同步配置
parse_upstream_config() {
    local conf_file="$1"
    if [ ! -f "$conf_file" ]; then
        echo "[ERROR] 上游配置文件不存在: $conf_file" >&2
        return 1
    fi

    # 初始化上游变量
    UP_TABLE_NAME=""
    SYNC_TYPE="FULL" 
    WHERE_CONDITION=""

    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        line=$(echo "$line" | xargs)
        local key=$(echo "$line" | awk -F'=' '{print $1}' | xargs)
        local value=$(echo "$line" | cut -d'=' -f2- | xargs)

        case "$key" in
            UP_TABLE_NAME) UP_TABLE_NAME="$value" ;;
            SYNC_TYPE)     SYNC_TYPE="$value" ;;
            WHERE_CONDITION) WHERE_CONDITION="$value" ;;
            *) echo "[WARN] 上游配置未知项: $key = $value" >&2 ;;
        esac
    done < "$conf_file"

    # 校验必填项
    if [ -z "$UP_TABLE_NAME" ]; then
        echo "[ERROR] 上游配置缺少必填项 (UP_TABLE_NAME): $conf_file" >&2
        return 1
    fi

    # 导出变量
    export UP_TABLE_NAME SYNC_TYPE WHERE_CONDITION
    return 0
}

# 2. 解析下游 ODS 建模配置
parse_ods_config() {
    local conf_file="$1"
    if [ ! -f "$conf_file" ]; then
        echo "[ERROR] ODS 配置文件不存在: $conf_file" >&2
        return 1
    fi

    # 初始化 ODS 变量（带默认值）
    ODS_DB_NAME=""
    ODS_TABLE_NAME=""
    IS_PARTITIONED="false"
    PARTITION_COL="dt"
    IS_DIM_TABLE="false"
    IS_TRANSACTION_TABLE="false"

    while IFS= read -r line || [ -n "$line" ]; do
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        line=$(echo "$line" | xargs)
        local key=$(echo "$line" | awk -F'=' '{print $1}' | xargs)
        local value=$(echo "$line" | cut -d'=' -f2- | xargs)

        case "$key" in
            ODS_DB_NAME)          ODS_DB_NAME="$value" ;;
            ODS_TABLE_NAME)       ODS_TABLE_NAME="$value" ;;
            IS_PARTITIONED)       IS_PARTITIONED="$value" ;;
            PARTITION_COL)        PARTITION_COL="$value" ;;
            IS_DIM_TABLE)         IS_DIM_TABLE="$value" ;;
            IS_TRANSACTION_TABLE) IS_TRANSACTION_TABLE="$value" ;;
            *) echo "[WARN] ODS 配置未知项: $key = $value" >&2 ;;
        esac
    done < "$conf_file"

    # 校验必填项
    if [ -z "$ODS_DB_NAME" ] || [ -z "$ODS_TABLE_NAME" ]; then
        echo "[ERROR] ODS 配置缺少必填项 (ODS_DB_NAME, ODS_TABLE_NAME): $conf_file" >&2
        return 1
    fi

    # 导出变量
    export ODS_DB_NAME ODS_TABLE_NAME IS_PARTITIONED PARTITION_COL IS_DIM_TABLE IS_TRANSACTION_TABLE
    return 0
}


# 获取 MySQL 表的字段信息并转换为 Hive 建表语句
# 参数: $1=MySQL表名, $2=Hive表名, $3=Hive库名
generate_hive_ddl_from_mysql() {
    local mysql_table=$1 hive_db=$2 hive_table=$3

    # 所有的调试信息，全部重定向到标准错误，不要污染标准输出
    echo "[INFO] 正在从 MySQL 实时获取表 [${mysql_table}] 的元数据..." >&2

    # 注意：这里使用 \t 作为分隔符，方便后续 awk 处理
    local metadata

    # 替换原来的 sqoop eval 逻辑
    # 注意：这里使用 \t (Tab) 作为分隔符，避免字段值中带有逗号导致解析错误
    metadata=$(mysql -h "$MYSQL_HOST" \
                    -P "$MYSQL_PORT" \
                    -u "$MYSQL_USER" \
                    -p"$MYSQL_PASS" \
                    -N -e "SELECT COLUMN_NAME, DATA_TYPE FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = '${MYSQL_DB}' AND TABLE_NAME = '${mysql_table}' ORDER BY ORDINAL_POSITION;" \
                    2>/dev/null)

    echo "[DEBUG] 获取到的原始元数据如下：" >&2
    echo "$metadata" | nl  >&2
    if [ -z "$metadata" ]; then
        echo "[ERROR] 无法获取表 [${mysql_table}] 的元数据，请检查表名或权限！" >&2
        return 1
    fi

    # 2. 遍历元数据，进行类型映射并拼接 Hive SQL
local -a col_array=() # 定义一个局部数组
    
    while IFS=$'\t' read -r col_name col_type; do
        # 优化：使用 Shell 内置的高性能去除首尾空格和双引号，不用再调外面的 tr 和 xargs 丢性能
        col_name="${col_name//\"/}"
        col_name=$(echo "$col_name") # 仅靠内置或最简去除
        col_type="${col_type//\"/}"
        
        # 简单的 MySQL -> Hive 类型映射
        local hive_type="STRING"
        case "${col_type,,}" in # ,, 自动转小写，防止 MySQL 类型大写时漏掉
            int|integer|tinyint|smallint|mediumint|bigint) hive_type="BIGINT" ;;
            float|double|decimal|numeric) hive_type="DOUBLE" ;;
            date) hive_type="DATE" ;;
            datetime|timestamp) hive_type="TIMESTAMP" ;;
            varchar|char|text|longtext|mediumtext) hive_type="STRING" ;;
        esac

        # 直接把单行字段定义塞进数组
        col_array+=("  \`${col_name}\` ${hive_type}")
        
    done <<< "$metadata"

    # 【关键重构】：用真正的“逗号 + 换行”把数组里的字段连起来
    local old_ifs="$IFS"
    IFS=$',\n'
    local hive_columns="${col_array[*]}"
    IFS="$old_ifs"

    # 3. 判断是否分区
    local partition_clause=""
    if [[ "$IS_PARTITIONED" == "true" ]]; then
        # 默认使用 dt 作为分区字段，如果配置了其他字段则使用配置的字段
        local p_col="${PARTITION_COL:-dt}"
        partition_clause="PARTITIONED BY (\`${p_col}\` STRING)"
    fi

    # # 4. 输出完整的 Hive 建表语句
    # 组装最终的 DDL 语句（赋值给全局变量，而不是 echo）
    GENERATED_SQL_PATH="$(pwd)/.tmp_hive_create_${ODS_TABLE_NAME}_$$.sql"
    cat > "${GENERATED_SQL_PATH}" << EOF
CREATE DATABASE IF NOT EXISTS ${hive_db};
USE ${hive_db};
CREATE TABLE IF NOT EXISTS ${ODS_DB_NAME}.${ODS_TABLE_NAME} (
${hive_columns}
)
COMMENT 'Auto-generated from MySQL: ${mysql_table}'
${partition_clause}
ROW FORMAT DELIMITED FIELDS TERMINATED BY "\t"
STORED AS TEXTFILE;
EOF
    #不能用STORED AS ORC（列式二进制存储格式）是因为TERMINATED BY "\t"会被自动忽略，后面load data会报尝试加载的文件格式与目标表的存储格式不匹配
    echo "[INFO] DDL 语句生成成功: ${ODS_DB_NAME}.${ODS_TABLE_NAME}" >&2
    return 0

}