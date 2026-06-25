-- =============================================================================
-- ADS 层装载模板: ads_user_age_category1_stat_day (维表关联版)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 优化点：通过等值 JOIN 关联 dim_age_range，消灭 DML 中的 CASE WHEN 硬编码，触发高效 MapJoin
-- =============================================================================

USE ${hiveconf:app_db};

INSERT OVERWRITE TABLE ${hiveconf:app_db}.ads_user_age_category1_stat_day PARTITION(dt='${hiveconf:do_date}')
SELECT 
    dws_sdd.sku_category1_id AS category1_id,
    dws_sdd.sku_category1_name AS category1_name,
    NVL(ar.age_group, '未知') AS age_group,
    SUM(dws_sdd.order_count) AS order_num,
    CAST(SUM(dws_sdd.order_amount) AS DECIMAL(16,2)) AS order_amount_all,
    CAST(SUM(dws_sdd.order_amount) / SUM(dws_sdd.order_count) AS DECIMAL(16,2)) AS order_amount_avg,
    '${hiveconf:do_date}' AS stat_day,
    current_timestamp() AS etl_time
FROM ${hiveconf:app_db}.dws_sale_detail_daycount dws_sdd
-- 核心优化：利用非等值条件进行区间判定，解决边界精度偏差
LEFT JOIN ${hiveconf:app_db}.dim_age_range ar 
  ON CAST(dws_sdd.user_age AS DECIMAL(5,2)) >= ar.down_limit 
 AND CAST(dws_sdd.user_age AS DECIMAL(5,2)) < ar.up_limit
WHERE dws_sdd.dt = '${hiveconf:do_date}'
GROUP BY 
    dws_sdd.sku_category1_id, 
    dws_sdd.sku_category1_name,
    NVL(ar.age_group, '未知');