-- =============================================================================
-- DWD 层数据装载模板: dim_user_info (用户维表)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: 继承ods_user_info，男女值转化，隐私信息打码，底层 ROW_NUMBER() 去重
-- =============================================================================

USE ${hiveconf:app_db};

INSERT OVERWRITE TABLE ${hiveconf:app_db}.dim_user_info PARTITION(dt='${hiveconf:do_date}')
SELECT 
    u.id,
    u.login_name,
    u.nick_name,
    u.name,
    CONCAT(SUBSTR(u.phone_num,1,3),'****',SUBSTR(u.phone_num,8,4)),
    u.email,
    u.user_level,
    u.birthday,
    (CASE WHEN u.gender='M' THEN '男' ELSE '女' END),
    u.create_time,
    current_timestamp() AS etl_time
FROM (
    -- 订单主表去重
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_user_info 
    WHERE dt='${hiveconf:do_date}'
) u
WHERE u.rn = 1;