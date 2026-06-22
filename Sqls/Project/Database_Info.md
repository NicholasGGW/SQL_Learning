### 商品信息模块

| 表名 | 中文名 | 字段名 | 类型(建议) | 描述 |
| :--- | :--- | :--- | :--- | :--- |
| `sku_info` | 商品表 | `id` | bigint | 库存ID(表内ID) |
| | | `spu_id` | bigint | 商品ID |
| | | `price` | decimal(10,2) | 价格 |
| | | `sku_name` | string | SKU名称 |
| | | `sku_desc` | string | 商品规格描述 |
| | | `weight` | decimal(10,2) | 重量 |
| | | `tm_id` | bigint | 品牌ID |
| | | `category3_id` | bigint | 三级分类ID |
| | | `sku_default_img` | string | 默认显示图片 |
| | | `create_time` | string | 创建时间 |
| `base_category1` | 一级分类表 | `id` | bigint | 编号 |
| | | `name` | string | 分类名称 |
| `base_category2` | 二级分类表 | `id` | bigint | 编号 |
| | | `name` | string | 二级分类名称 |
| | | `category1_id` | bigint | 一级分类编号 |
| `base_category3` | 三级分类表 | `id` | bigint | 编号 |
| | | `name` | string | 三级分类名称 |
| | | `category2_id` | bigint | 二级分类编号 |

### 订单模块

| 表名 | 中文名 | 字段名 | 类型(建议) | 描述 |
| :--- | :--- | :--- | :--- | :--- |
| `order_detail` | 订单明细表 | `id` | bigint | 编号 |
| | | `order_id` | bigint | 订单编号 |
| | | `sku_id` | bigint | 商品SKU编号 |
| | | `sku_name` | string | 商品名称(冗余) |
| | | `img_url` | string | 图片名称(冗余) |
| | | `order_price` | decimal(10,2) | 购买价格(下单时sku价格) |
| | | `sku_num` | bigint | 购买个数 |
| `order_info` | 订单表 | `id` | bigint | 编号 |
| | | `consignee` | string | 收货人 |
| | | `consignee_tel` | string | 收件人电话 |
| | | `total_amount` | decimal(10,2) | 总金额 |
| | | `order_status` | string | 订单状态 |
| | | `user_id` | bigint | 用户ID |
| | | `payment_way` | string | 付款方式 |
| | | `delivery_address` | string | 送货地址 |
| | | `order_comment` | string | 订单备注 |
| | | `out_trade_no` | string | 订单交易编号(第三方支付用) |
| | | `trade_body` | string | 订单描述(第三方支付用) |
| | | `create_time` | string | 创建时间 |
| | | `operate_time` | string | 操作时间 |
| | | `expire_time` | string | 失效时间 |
| | | `tracking_no` | string | 物流单编号 |
| | | `parent_order_id` | bigint | 父订单编号 |
| | | `img_url` | string | 图片路径 |
| `payment_info` | 支付流水表 | `id` | bigint | 编号 |
| | | `out_trade_no` | string | 对外业务编号 |
| | | `order_id` | bigint | 订单编号 |
| | | `user_id` | bigint | 用户编号 |
| | | `alipay_trade_no` | string | 支付宝交易流水编号 |
| | | `total_amount` | decimal(10,2) | 支付金额 |
| | | `subject` | string | 交易内容 |
| | | `payment_type` | string | 支付方式 |
| | | `payment_time` | string | 支付时间 |



### 用户模块
| 表名 | 中文名 | 字段名 | 类型(建议) | 描述 |
| :--- | :--- | :--- | :--- | :--- |
| `user_info` | 用户表 | `id` | bigint | 编号 |
| | | `login_name` | string | 用户名 |
| | | `nick_name` | string | 用户昵称 |
| | | `passwd` | string | 用户密码 |
| | | `name` | string | 用户姓名 |
| | | `phone_num` | string | 手机号 |
| | | `email` | string | 邮箱 |
| | | `head_img` | string | 头像 |
| | | `user_level` | string | 用户级别 |
| | | `birthday` | string | 生日 |
| | | `gender` | string | 性别 M男,F女 |
| | | `create_time` | string | 创建时间 |

