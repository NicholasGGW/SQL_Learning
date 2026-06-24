# 电商数仓 DWS 层表结构设计规范
用户行为表
下单和不下单都是一种行为
下单表+支付表 代表 下单购买
下单表+不支付 代表 下单但不购买
不下单 代表 没下单

长期没有下单有可能用户流失

同一个订单下单和支付有可能会跨天
时间维表，每天都有

user_id = BIGINT | dim_user_info.id
order_date = STRING | dim_date.date_full
order_count = BIGINT | dwd_order_info.id
order_amount = DESIMAL | dwd_order_info.total_amount
payment_count = BIGINT | dwd_payment_info.id
payment_amount = DESIMAL | dwd_payment_info.total_amount


那也可以分析用户在什么时段最爱下单
什么时段最爱取消支付
什么商品类型最容易被取消支付


用户购买商品明细表
user_id
create_time
sku_id

userage 使用月份差 birthday 



## 一、 ODS 层（贴源层）表结构信息补全
根据 Sqoop 导入日志及 MySQL 元数据映射，Hive 中的 ODS 层表结构定义如下（包含按天分区字段 `dt`）。注意金额和重量等数值字段在 Sqoop 自动建表时被转换为 `DOUBLE` 类型，时间被转为 `TIMESTAMP`。

### 1. 商品信息模块
* **`ods_sku_info` (商品表)**
  * `id` (BIGINT): 库存ID(表内ID)
  * `spu_id` (BIGINT): 商品ID
  * `price` (DOUBLE): 价格
  * `sku_name` (STRING): SKU名称
  * `sku_desc` (STRING): 商品规格描述
  * `weight` (DOUBLE): 重量
  * `tm_id` (BIGINT): 品牌ID
  * `category3_id` (BIGINT): 三级分类ID
  * `sku_default_img` (STRING): 默认显示图片
  * `create_time` (TIMESTAMP): 创建时间
  * `dt` (STRING): 分区字段(按天)
* **`ods_base_category1` (一级分类表)**
  * `id` (BIGINT): 编号
  * `name` (STRING): 分类名称
  * `dt` (STRING): 分区字段(按天)
* **`ods_base_category2` (二级分类表)**
  * `id` (BIGINT): 编号
  * `name` (STRING): 二级分类名称
  * `category1_id` (BIGINT): 一级分类编号
  * `dt` (STRING): 分区字段(按天)
* **`ods_base_category3` (三级分类表)**
  * `id` (BIGINT): 编号
  * `name` (STRING): 三级分类名称
  * `category2_id` (BIGINT): 二级分类编号
  * `dt` (STRING): 分区字段(按天)

### 2. 订单模块
* **`ods_order_detail` (订单明细表)**
  * `id` (BIGINT): 编号
  * `order_id` (BIGINT): 订单编号
  * `sku_id` (BIGINT): 商品SKU编号
  * `sku_name` (STRING): 商品名称(冗余)
  * `img_url` (STRING): 图片名称(冗余)
  * `order_price` (DOUBLE): 购买价格
  * `sku_num` (STRING): 购买个数
  * `dt` (STRING): 分区字段(按天)
* **`ods_order_info` (订单表)**
  * `id` (BIGINT): 编号
  * `consignee` (STRING): 收货人
  * `consignee_tel` (STRING): 收件人电话
  * `total_amount` (DOUBLE): 总金额
  * `order_status` (STRING): 订单状态
  * `user_id` (BIGINT): 用户ID
  * `payment_way` (STRING): 付款方式
  * `delivery_address` (STRING): 送货地址
  * `order_comment` (STRING): 订单备注
  * `out_trade_no` (STRING): 订单交易编号
  * `trade_body` (STRING): 订单描述
  * `create_time` (TIMESTAMP): 创建时间
  * `operate_time` (TIMESTAMP): 操作时间
  * `expire_time` (TIMESTAMP): 失效时间
  * `tracking_no` (STRING): 物流单编号
  * `parent_order_id` (BIGINT): 父订单编号
  * `img_url` (STRING): 图片路径
  * `dt` (STRING): 分区字段(按天)
* **`ods_payment_info` (支付流水表)**
  * `id` (BIGINT): 编号
  * `out_trade_no` (STRING): 对外业务编号
  * `order_id` (STRING): 订单编号
  * `user_id` (STRING): 用户编号
  * `alipay_trade_no` (STRING): 支付宝交易流水编号
  * `total_amount` (DOUBLE): 支付金额
  * `subject` (STRING): 交易内容
  * `payment_type` (STRING): 支付方式
  * `payment_time` (STRING): 支付时间
  * `dt` (STRING): 分区字段(按天)

### 3. 用户模块
* **`ods_user_info` (用户表)**
  * `id` (BIGINT): 编号
  * `login_name` (STRING): 用户名
  * `nick_name` (STRING): 用户昵称
  * `passwd` (STRING): 用户密码
  * `name` (STRING): 用户姓名
  * `phone_num` (STRING): 手机号
  * `email` (STRING): 邮箱
  * `head_img` (STRING): 头像
  * `user_level` (STRING): 用户级别
  * `birthday` (STRING): 生日
  * `gender` (STRING): 性别 M男,F女
  * `create_time` (TIMESTAMP): 创建时间
  * `dt` (STRING): 分区字段(按天)

---

## 二、 DWD 层（明细层）模型设计规范
在 DWD 层，通过维度退化减少 JOIN 损耗，高精度金额字段转换回 `DECIMAL(16,2)`，敏感数据进行脱敏。

### 1. 维度表（DIM）
* `dim_sku_info`: 商品维度宽表，打平了一、二、三级类目名称。
* `dim_user_info`: 用户维度表，剔除密码敏感字段(passwd, head_img)，对手机号进行脱敏处理。

### 2. 事实表（FACT）
* `dwd_fact_order_detail`: 订单明细事实表，继承ods_order_detail。
* `dwd_fact_order_info`: 订单主表，继承ods_order_info。
* `dwd_fact_payment_info`: 支付明细事实表，对订单ID和用户ID进行了类型规范化（转为BIGINT）。
