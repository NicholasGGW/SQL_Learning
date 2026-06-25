-- =============================================================================
-- ADS 层装载模板: ads_sale_tm_category1_stat_mn
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: 按品牌和一级品类双维度聚合，使用 DWS 轻度汇总天分区数据，
--           通过前置 CTE 统计用户月度累计频次，进而计算各级复购人数和比例。
-- =============================================================================

USE ${hiveconf:app_db};

WITH user_month_orders AS (
    -- 1. 前置过滤计算当前月度内每个用户购买特定品牌/品类的累计次数
    SELECT 
        user_id,
        sku_tm_id AS tm_id,
        sku_category1_id AS category1_id,
        sku_category1_name AS category1_name,
        SUM(order_count) AS user_order_count
    FROM ${hiveconf:app_db}.dws_sale_detail_daycount
    --这种写法是比较符合工作流程的，因为最前面ods是的dt=前一天是抽取UPDATE_DATE前一天的
    --WHERE substr(dt, 1, 7) = substr('${hiveconf:do_date}', 1, 7) 
    WHERE dt = '${hiveconf:do_date}'
    GROUP BY user_id, sku_tm_id, sku_category1_id, sku_category1_name
)
INSERT OVERWRITE TABLE ${hiveconf:app_db}.ads_sale_tm_category1_stat_mn PARTITION(dt='${hiveconf:do_date}')
SELECT 
    tm_id,
    category1_id,
    category1_name,
    -- 购买人数
    COUNT(DISTINCT user_id) AS buycount,
    -- 2次及以上购买人数
    SUM(CASE WHEN user_order_count >= 2 THEN 1 ELSE 0 END) AS buy_twice_last,
    -- 单次复购率
    CAST(SUM(CASE WHEN user_order_count >= 2 THEN 1.0 ELSE 0.0 END) / COUNT(DISTINCT user_id) AS DECIMAL(16,4)) AS buy_twice_last_ratio,
    -- 3次及以上购买人数
    SUM(CASE WHEN user_order_count >= 3 THEN 1 ELSE 0 END) AS buy_3times_last,
    -- 多次复购率
    CAST(SUM(CASE WHEN user_order_count >= 3 THEN 1.0 ELSE 0.0 END) / COUNT(DISTINCT user_id) AS DECIMAL(16,4)) AS buy_3times_last_ratio,
    substr('${hiveconf:do_date}', 1, 7) AS stat_mn,
    '${hiveconf:do_date}' AS stat_date,
    current_timestamp() AS etl_time
FROM user_month_orders
GROUP BY tm_id, category1_id, category1_name;