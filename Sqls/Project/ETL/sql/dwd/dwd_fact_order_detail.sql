-- =============================================================================
-- DWD 层数据装载模板: dwd_fact_order_detail (订单明细事实表)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: 底层 ROW_NUMBER() 去重
-- =============================================================================

USE ${hiveconf:app_db};

INSERT OVERWRITE TABLE ${hiveconf:app_db}.dwd_fact_order_detail PARTITION(dt='${hiveconf:do_date}')
SELECT 
    od.id, 
    od.order_id, 
    od.sku_id, 
    od.sku_name,
    od.img_url,
    CAST(od.order_price AS DECIMAL(16,2)), 
    CAST(od.sku_num AS BIGINT)
FROM (
    -- 订单明细表去重
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_order_detail 
    WHERE dt='${hiveconf:do_date}'
) od
WHERE od.rn = 1;