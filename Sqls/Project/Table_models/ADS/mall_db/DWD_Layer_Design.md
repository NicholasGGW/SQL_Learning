### 电商数仓 ADS 层设计规范说明书

1. 业务需求背景

为了更好地支持 BI 报表呈现与业务决策：

ads_user_age_category1_stat_day (用户年龄段及品类日汇总表)：从年龄和品类两个核心维度切入，分析不同年龄层群体对各一级品类的购买力偏好、订单频次及件单价趋势，用以支持精准营销与商品画像推荐。

ads_sale_tm_category1_stat_mn (品牌与品类月复购率表)：按月度统计各品牌在各一级品类下的用户复购行为（购买 2 次及以上、3 次及以上的复购人数及占比），用来评估品牌粘性与品类的复购健康度。

2. 表模型定义与加载策略

所有表均采用 TEXTFILE 格式供下游使用，使用 \t 作为列分隔符。

为了确保离线数仓的幂等性：

年龄计算：严禁使用 CURRENT_DATE，统一采用调度跑批时传入的业务日期 ${hiveconf:do_date} 计算用户周岁，并进行分段归纳。

复购统计：拉取跑批日期对应月份的全天 DWS 数据进行重组聚合。

1. 字段信息补全

① ads_user_age_category1_stat_day


| 字段名 | 字段描述 | 类型 | 主键 | 可空 | 来源表/清洗逻辑 |
|---|---|---|---|---|---|
| category1_id | 一级品类ID | BIGINT | Y | N | dws_sale_detail_daycount.sku_category1_id |
| category1_name | 一级品类名称 | STRING | N | N | dws_sale_detail_daycount.sku_category1_name |
| age_group | 年龄段 | STRING | Y | N | CASE 转换：依据 user_age 划定 '0-9', '10-19', '20-29', '30-39', '40-49', '50+' |
| order_num | 订单数 | BIGINT | N | Y | SUM(order_count) |
| order_amount_all | 订单总金额 | DECIMAL(16,2) | N | Y | SUM(order_amount) |
| order_amount_avg | 平均单价 | DECIMAL(16,2) | N | Y | SUM(order_amount) / SUM(order_count) |
| stat_day | 汇总日期 | STRING | N | N | ${hiveconf:do_date} |
| etl_time | 处理时间 | TIMESTAMP | N | N | current_timestamp() |

② ads_sale_tm_category1_stat_mn

| 字段名 | 字段描述 | 类型 | 主键 | 可空 | 来源表/清洗逻辑 |
|---|---|---|---|---|---|
| tm_id | 品牌ID | BIGINT | Y | N | dws_sale_detail_daycount.sku_tm_id |
| category1_id | 一级品类ID | BIGINT | Y | N | dws_sale_detail_daycount.sku_category1_id |
| category1_name | 一级品类名称 | STRING | N | Y | dws_sale_detail_daycount.sku_category1_name |
| buycount | 购买人数 | BIGINT | N | Y | 按月分组，COUNT(DISTINCT user_id) |
| buy_twice_last | 两次及以上购买人数 | BIGINT | N | Y | 按月分组，统计购买频次 >= 2 的用户数 |
| buy_twice_last_ratio | 单次复购率 | DECIMAL(16,4) | N | Y | buy_twice_last / buycount |
| buy_3times_last | 三次及以上购买人数 | BIGINT | N | Y | 按月分组，统计购买频次 >= 3 的用户数 |
| buy_3times_last_ratio | 多次复购率 | DECIMAL(16,4) | N | Y | buy_3times_last / buycount |
| stat_mn | 统计月份 | STRING | N | N | ${hiveconf:do_date} 对应的 'yyyy-MM' |
| stat_date | 汇总日期 | STRING | Y | N | ${hiveconf:do_date} |
| etl_time | 处理时间 | TIMESTAMP | N | N | current_timestamp() |