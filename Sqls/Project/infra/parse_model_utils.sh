#!/bin/bash
# infra/parse_model_utils.sh

# 通用解析函数
# 参数: $1=配置文件路径
# 功能: 解析文件并导出全局变量 TABLE_NAME, COMMENT, FIELD_LIST_SQL
parse_table_config() {
    local conf_file=$1

    if [ ! -f "$conf_file" ]; then
        echo "[ERROR] 配置文件不存在: $conf_file"
        return 1
    fi

    # 初始化变量
    TABLE_NAME=""
    TABLE_COMMENT=""
    FIELD_LIST_SQL="" # 用于拼接 "col1 type1, col2 type2"
    FIELD_NAMES_CSV="" # 用于拼接 "col1, col2"

    local in_fields=0

    while IFS= read -r line; do
        # 跳过注释和空行
        [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

        # 识别段落
        if [[ "$line" == "[GLOBAL]" ]]; then
            in_fields=0
            continue
        elif [[ "$line" == "[FIELDS]" ]]; then
            in_fields=1
            continue
        fi

        # 解析 Global 部分
        if [ $in_fields -eq 0 ]; then
            key=$(echo "$line" | cut -d'=' -f1)
            value=$(echo "$line" | cut -d'=' -f2-)
            case "$key" in
                TABLE_NAME) TABLE_NAME="$value" ;;
                COMMENT) TABLE_COMMENT="$value" ;;
            esac
        fi

        # 解析 Fields 部分 (格式: name|type|null|comment)
        if [ $in_fields -eq 1 ]; then
            f_name=$(echo "$line" | awk -F'|' '{print $1}')
            f_type=$(echo "$line" | awk -F'|' '{print $2}')
            f_null=$(echo "$line" | awk -F'|' '{print $3}')
            f_comm=$(echo "$line" | awk -F'|' '{print $4}')

            # 拼接 SQL 片段
            if [ -n "$FIELD_LIST_SQL" ]; then
                FIELD_LIST_SQL="${FIELD_LIST_SQL},"
                FIELD_NAMES_CSV="${FIELD_NAMES_CSV},"
            fi
            FIELD_LIST_SQL="${FIELD_LIST_SQL} ${f_name} ${f_type} ${f_null} COMMENT '${f_comm}'"
            FIELD_NAMES_CSV="${FIELD_NAMES_CSV} ${f_name}"
        fi
    done < "$conf_file"

    # 导出变量供调用者使用
    export TABLE_NAME TABLE_COMMENT FIELD_LIST_SQL FIELD_NAMES_CSV
    return 0
}