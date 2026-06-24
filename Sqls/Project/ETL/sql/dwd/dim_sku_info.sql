-- =============================================================================
-- DWD 层数据装载模板: dim_sku_info (商品维度宽表)
-- 接收参数: ${hiveconf:app_db}, ${hiveconf:do_date}
-- 核心逻辑: 结合 ODS 表进行维度退化，使用 ROW_NUMBER() 实现底层幂等去重
-- =============================================================================

USE ${hiveconf:app_db};

-- 开启本地模式或优化器参数 (视集群情况配置)
-- set hive.exec.mode.local.auto=true;

INSERT OVERWRITE TABLE ${hiveconf:app_db}.dim_sku_info PARTITION(dt='${hiveconf:do_date}')
SELECT 
    sku.id, 
    sku.spu_id, 
    CAST(sku.price AS DECIMAL(16,2)), 
    sku.sku_name, 
    sku.sku_desc, 
    CAST(sku.weight AS DECIMAL(16,2)), 
    sku.tm_id, 
    sku.category3_id, 
    sku.sku_default_img,
    sku.create_time,
    c3.name, 
    c3.category2_id, 
    c2.name, 
    c2.category1_id, 
    c1.name,
    current_timestamp() AS etl_time
FROM (
    -- ODS 源表去重获取最新快照
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY create_time DESC) as rn 
    FROM ${hiveconf:app_db}.ods_sku_info 
    WHERE dt='${hiveconf:do_date}'
) sku
LEFT JOIN (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_base_category3 
    WHERE dt='${hiveconf:do_date}'
) c3 ON sku.category3_id = c3.id AND c3.rn = 1
LEFT JOIN (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_base_category2 
    WHERE dt='${hiveconf:do_date}'
) c2 ON c3.category2_id = c2.id AND c2.rn = 1
LEFT JOIN (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as rn 
    FROM ${hiveconf:app_db}.ods_base_category1 
    WHERE dt='${hiveconf:do_date}'
) c1 ON c2.category1_id = c1.id AND c1.rn = 1
WHERE sku.rn = 1;