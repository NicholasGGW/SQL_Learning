-- =============================================================================
-- DWD 层数据装载模板: dwd_fact_order_detail (订单明细事实表)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: 订单明细与订单主表关联，退化公共状态字段，底层 ROW_NUMBER() 去重
-- =============================================================================

USE ${hiveconf:app_db};

INSERT OVERWRITE TABLE ${hiveconf:app_db}.dwd_fact_order_detail PARTITION(dt='${hiveconf:do_date}')
SELECT 
    od.id, 
    od.order_id, 
    oi.user_id, 
    od.sku_id, 
    od.sku_name,
    CAST(od.order_price AS DECIMAL(16,2)), 
    CAST(od.sku_num AS BIGINT),
    oi.order_status, 
    oi.create_time
FROM (
    -- 订单明细表去重
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_order_detail 
    WHERE dt='${hiveconf:do_date}'
) od
LEFT JOIN (
    -- 订单主表取最新状态记录
    SELECT id, user_id, order_status, create_time,
           ROW_NUMBER() OVER(PARTITION BY id ORDER BY operate_time DESC) as rn 
    FROM ${hiveconf:app_db}.ods_order_info 
    WHERE dt='${hiveconf:do_date}'
) oi ON od.order_id = oi.id AND oi.rn = 1
WHERE od.rn = 1;