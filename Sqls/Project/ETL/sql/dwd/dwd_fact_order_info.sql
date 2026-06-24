-- =============================================================================
-- DWD 层数据装载模板: dwd_fact_order_info (订单总事实表)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: ROW_NUMBER() 去重
-- =============================================================================

USE ${hiveconf:app_db};

INSERT OVERWRITE TABLE ${hiveconf:app_db}.dwd_fact_order_info PARTITION(dt='${hiveconf:do_date}')
SELECT 
    oi.id, 
    oi.consignee, 
    oi.consignee_tel, 
    CAST(oi.total_amount AS DECIMAL(16,2)), 
    oi.order_status, 
    oi.user_id, 
    oi.payment_way, 
    oi.delivery_address, 
    oi.order_comment, 
    oi.out_trade_no, 
    oi.trade_body, 
    oi.create_time, 
    oi.operate_time, 
    oi.expire_time, 
    oi.tracking_no, 
    oi.parent_order_id, 
    oi.img_url,
    current_timestamp() AS etl_time
FROM (
    -- 订单主表去重
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_order_info 
    WHERE dt='${hiveconf:do_date}'
) oi
WHERE oi.rn = 1;