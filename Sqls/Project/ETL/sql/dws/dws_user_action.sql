-- =============================================================================
-- DWS 层装载模板: dws_user_action
-- 采用 FULL OUTER JOIN 聚合单日内有下单或有支付行为的所有活跃用户
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- =============================================================================

USE ${hiveconf:app_db};

WITH order_agg AS (
    SELECT 
        user_id, 
        TO_DATE(create_time) AS order_date,
        COUNT(id) AS order_count, 
        SUM(total_amount) AS order_amount
    FROM ${hiveconf:app_db}.dwd_fact_order_info 
    WHERE dt = '${hiveconf:do_date}'
    GROUP BY user_id, TO_DATE(create_time)
),
payment_agg AS (
    SELECT 
        user_id, 
        TO_DATE(payment_time) AS order_date,
        COUNT(id) AS payment_count, 
        SUM(total_amount) AS payment_amount
    FROM ${hiveconf:app_db}.dwd_fact_payment_info 
    WHERE dt = '${hiveconf:do_date}'
    GROUP BY user_id, TO_DATE(payment_time)
)
INSERT OVERWRITE TABLE ${hiveconf:app_db}.dws_user_action PARTITION(dt='${hiveconf:do_date}')
SELECT 
    u.id AS user_id,
    dim_date.date_full AS order_date,
    NVL(o.order_count, 0) AS order_count,
    CAST(NVL(o.order_amount, 0.00) AS DECIMAL(16,2)) AS order_amount,
    NVL(p.payment_count, 0) AS payment_count,
    CAST(NVL(p.payment_amount, 0.00) AS DECIMAL(16,2)) AS payment_amount,
    current_timestamp() AS etl_time
FROM ${hiveconf:app_db}.dim_user_info u
FULL JOIN ${hiveconf:app_db}.dim_date ON 1=1
LEFT JOIN order_agg o ON 
    u.id = o.user_id AND o.order_date = dim_date.date_full
FULL OUTER JOIN payment_agg p ON 
    u.id = p.user_id AND p.order_date = dim_date.date_full;