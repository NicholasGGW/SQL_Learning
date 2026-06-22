#!/bin/bash
# /infra/check_sql_connect.sh

# 检查 MySQL 连接
check_mysql_conn() {
    local jdbc=$1 user=$2 pass=$3
    echo "[INFO] 正在检查 MySQL 连接..."
    sqoop eval --connect "$jdbc" --username "$user" --password "$pass" --query "SELECT 1" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR] MySQL 连接失败！"
        return 1
    fi
    echo "[INFO] MySQL 连接成功。"
    return 0
}

# 检查 MySQL 表是否存在
check_mysql_table() {
    local jdbc=$1 user=$2 pass=$3 table=$4
    echo "[INFO] 正在检查 MySQL 表 [${table}] 是否存在..."
    sqoop eval --connect "$jdbc" --username "$user" --password "$pass" --query "SELECT * FROM ${table} LIMIT 1" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "[ERROR] MySQL 表 [${table}] 不存在！"
        return 1
    fi
    echo "[INFO] MySQL 表 [${table}] 存在。"
    return 0
}

# 检查 Hive 表是否存在
check_hive_table() {
    local db=$1 table=$2
    echo "[INFO] 正在检查 Hive 表 [${db}.${table}] 是否存在..."
    hive -e "SHOW TABLES IN ${db} LIKE '${table}';" 2>/dev/null | grep -q "^${table}$"
    if [ $? -ne 0 ]; then
        echo "[WARN] Hive 表 [${db}.${table}] 不存在。"
        return 1
    fi
    echo "[INFO] Hive 表 [${db}.${table}] 已存在。"
    return 0
}