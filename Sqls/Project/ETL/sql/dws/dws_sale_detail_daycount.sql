-- =============================================================================
-- DWS 层装载模板: dws_sale_detail_daycount
-- 由于订单未在DWD层打平，此处需先关联 order_info 和 order_detail 提取单日事实
-- 再关联 user 与 sku 维度表获取退化属性。年龄计算严格依赖 do_date。
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- =============================================================================

USE ${hiveconf:app_db};

WITH daily_order_detail AS (
    -- 先在事实表粒度完成聚合与关联，降低输出给下游的数据量
    SELECT 
        oi.user_id,
        TO_DATE(oi.create_time) AS order_date,
        od.sku_id,
        SUM(od.sku_num) AS sku_num,
        COUNT(DISTINCT od.order_id) AS order_count,
        SUM(od.order_price * od.sku_num) AS order_amount
    FROM ${hiveconf:app_db}.dwd_fact_order_detail od
    JOIN ${hiveconf:app_db}.dwd_fact_order_info oi 
      ON od.order_id = oi.id
    WHERE od.dt = '${hiveconf:do_date}' 
      AND oi.dt = '${hiveconf:do_date}'
    GROUP BY oi.user_id, TO_DATE(oi.create_time), od.sku_id
)
INSERT OVERWRITE TABLE ${hiveconf:app_db}.dws_sale_detail_daycount PARTITION(dt='${hiveconf:do_date}')
SELECT 
    dod.user_id,
    dod.order_date,
    dod.sku_id,
    u.gender AS user_gender,
    CAST(ROUND(ROUND(MONTHS_BETWEEN('${do_date}', birthday),0) / 12, 2) AS STRING) AS user_age,
    u.user_level,
    s.price AS sku_price,
    s.sku_name,
    s.tm_id AS sku_tm_id,
    s.category3_id AS sku_category3_id,
    s.category2_id AS sku_category2_id,
    s.category1_id AS sku_category1_id,
    s.category3_name AS sku_category3_name,
    s.category2_name AS sku_category2_name,
    s.category1_name AS sku_category1_name,
    s.spu_id,
    dod.sku_num,
    dod.order_count,
    CAST(dod.order_amount AS DECIMAL(16,2)) AS order_amount
FROM daily_order_detail dod
LEFT JOIN ${hiveconf:app_db}.dim_user_info u 
  ON dod.user_id = u.id AND u.dt = '${hiveconf:do_date}'
LEFT JOIN ${hiveconf:app_db}.dim_sku_info s 
  ON dod.sku_id = s.sku_id AND s.dt = '${hiveconf:do_date}';