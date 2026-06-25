-- =============================================================================
-- ADS 层装载模板: ads_user_age_category1_stat_day (双路归集对账防漏 - CROSS JOIN 避错版)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑:
-- 1. 动态获取年龄维表的最小下限与最大上限。
-- 2. 路由 A：改用 CROSS JOIN 并在 WHERE 中进行非等值过滤，完美绕过 Hive 对非等值 JOIN ON 的编译局限。
-- 3. 路由 B：未命中的孤儿数据（空值、超龄、负数），统一归入 '未知' 兜底。
-- 4. 维度补全层 CROSS JOIN 追加 '未知' 成员，确保异常数据 100% 能够被等值 LEFT JOIN 呈现。
-- =============================================================================

USE ${hiveconf:app_db};
set hive.exec.parallel=true;
WITH min_max_age AS (
    -- 1. 动态提取维表的边界，防止维表硬编码调整后失效
    SELECT 
        MIN(down_limit) AS global_min,
        MAX(up_limit) AS global_max
    FROM ${hiveconf:app_db}.dim_age_range
),
joined_facts AS (
    -- 2. 路由 A：正常命中的高精度数据 
    -- 避坑关键：改用 CROSS JOIN 并在 WHERE 中进行非等值过滤，彻底解决 Error 10017 报错
    SELECT 
        dws.sku_category1_id,
        dws.sku_category1_name,
        ar.age_group,
        dws.order_count,
        dws.order_amount
    FROM ${hiveconf:app_db}.dws_sale_detail_daycount dws
    CROSS JOIN ${hiveconf:app_db}.dim_age_range ar
    WHERE dws.dt = '${hiveconf:do_date}'
      AND CAST(dws.user_age AS DECIMAL(5,2)) >= ar.down_limit 
      AND CAST(dws.user_age AS DECIMAL(5,2)) < ar.up_limit

    UNION ALL

    -- 3. 路由 B：未命中的孤儿数据（空值、超龄、负数），统一归入 '未知' 兜底
    SELECT 
        dws.sku_category1_id,
        dws.sku_category1_name,
        '未知' AS age_group,
        dws.order_count,
        dws.order_amount
    FROM ${hiveconf:app_db}.dws_sale_detail_daycount dws
    CROSS JOIN min_max_age mm
    WHERE dws.dt = '${hiveconf:do_date}'
      AND (
        dws.user_age IS NULL 
        OR CAST(dws.user_age AS DECIMAL(5,2)) < mm.global_min 
        OR CAST(dws.user_age AS DECIMAL(5,2)) >= mm.global_max
      )
),
aggregated_facts AS (
    -- 4. 在事实表粒度完成合并后的轻度聚合
    SELECT 
        sku_category1_id,
        sku_category1_name,
        age_group,
        SUM(order_count) AS order_num,
        SUM(order_amount) AS order_amount_all
    FROM joined_facts
    GROUP BY sku_category1_id, sku_category1_name, age_group
),
active_categories AS (
    -- 5. 提取当日产生活跃交易的一级品类作为业务维度基准
    --后续可以优化成全一级品类
    SELECT DISTINCT 
        sku_category1_id AS category1_id, 
        sku_category1_name AS category1_name
    FROM ${hiveconf:app_db}.dws_sale_detail_daycount
    WHERE dt = '${hiveconf:do_date}'
),
age_groups AS (
    -- 6. 从维度表中捞出所有的标准年龄段，并动态追加 '未知' 分组，作为对账矩阵主表
    SELECT DISTINCT age_group FROM ${hiveconf:app_db}.dim_age_range
    UNION
    SELECT '未知' AS age_group
)
INSERT OVERWRITE TABLE ${hiveconf:app_db}.ads_user_age_category1_stat_day PARTITION(dt='${hiveconf:do_date}')
SELECT 
    c.category1_id,
    c.category1_name,
    ag.age_group,
    NVL(f.order_num, 0) AS order_num,
    CAST(NVL(f.order_amount_all, 0.00) AS DECIMAL(16,2)) AS order_amount_all,
    -- 避免除以 0 的情况出现
    CAST(
        CASE 
            WHEN NVL(f.order_num, 0) = 0 THEN 0.00 
            ELSE NVL(f.order_amount_all, 0.00) / f.order_num 
        END AS DECIMAL(16,2)
    ) AS order_amount_avg,
    '${hiveconf:do_date}' AS stat_day,
    current_timestamp() AS etl_time
-- 7. 通过 CROSS JOIN 暴力生成 [品类 × 所有年龄段(含未知)] 的完整行网格
FROM active_categories c
CROSS JOIN age_groups ag
-- 8. 与预聚合的事实表进行标准等值 LEFT JOIN，完美防丢
LEFT JOIN aggregated_facts f
  ON c.category1_id = f.sku_category1_id 
 AND ag.age_group = f.age_group;