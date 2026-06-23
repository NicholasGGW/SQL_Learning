-- =============================================================================
-- DWD 层数据装载模板: dwd_fact_payment_info (订单总事实表)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: ROW_NUMBER() 去重
-- =============================================================================

USE ${hiveconf:app_db};

INSERT OVERWRITE TABLE ${hiveconf:app_db}.dwd_fact_payment_info PARTITION(dt='${hiveconf:do_date}')
SELECT 
    pi.id, 
    pi.out_trade_no,
    pi.order_id,
    pi.user_id,
    pi.alipay_trade_no,
    pi.total_amount,
    pi.subject,
    pi.payment_type,
    pi.payment_time
FROM (
    -- 去重
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_payment_info 
    WHERE dt='${hiveconf:do_date}'
) pi
WHERE pi.rn = 1;