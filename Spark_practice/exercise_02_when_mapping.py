# -*- coding: utf-8 -*-
"""
习题 02 — 条件映射：原始中文状态 -> 统一状态机
对应项目：clean_issue.py 的"问题单状态标准化"（核心清洗规则）。

------------------------------ 要求 ------------------------------
输入：mock_data/ods_issue_ticket.csv
任务：新增一列 std_status，按下表映射 raw_status；其余列保留：
    新建        -> open
    已分析/修改中 -> in_progress
    待验证       -> resolved
    已关闭       -> closed
    已拒绝       -> rejected
    挂起         -> suspended
    重开         -> reopened

pandas 对照：
    df["std_status"] = df["raw_status"].map(mapping)

Spark 三种常见写法（任选其一体会）：
  A) F.when(F.col("raw_status")=="新建","open").when(...).otherwise(...)
  B) 先建映射表 create_map，再 F[mapping_expr]
  C) 把映射做成小 DataFrame，broadcast join（习题03会专门练 join，这里建议先用 A）

新增列用 df.withColumn("std_status", 表达式)

提示算子：F.when, F.col, df.withColumn
自检：python check.py 02
-----------------------------------------------------------------
"""
from pyspark.sql import DataFrame, functions as F
from _utils import get_spark, read


def solve(spark) -> DataFrame:
    issue = read(spark, "ods_issue_ticket.csv")
    
    result_df = issue.withColumn(
        "std_status",
        F.when(F.col("raw_status") == "新建", "open")
         .when(F.col("raw_status") == "已分析", "in_progress")
         .when(F.col("raw_status") == "修改中", "in_progress")
         .when(F.col("raw_status") == "待验证", "resolved")
         .when(F.col("raw_status") == "已关闭", "closed")
         .when(F.col("raw_status") == "已拒绝", "rejected")
         .when(F.col("raw_status") == "挂起", "suspended")
         .when(F.col("raw_status") == "重开", "reopened")
         .otherwise(None)  # 如果没有匹配的状态，可以设置为 None 或其他默认值
    )

    dict_mapping = {
        "新建": "open",
        "已分析": "in_progress",
        "修改中": "in_progress",
        "待验证": "resolved",
        "已关闭": "closed",
        "已拒绝": "rejected",
        "挂起": "suspended",
        "重开": "reopened"
    }
    #F.col("raw_status").show() #没有这个方法
    
# 语法：df.withColumn("列名", 表达式)。
# 功能：如果列名是新的，则添加该列；如果列名已存在，则替换该列。
# 关键点：它接受一个列表达式（通常是 F.col 加上操作、F.when、UDF 等）。它返回一个新的 DataFrame（不可变性）。
    # result_df2 = issue.withColumn(   
    #     "std_status", dict_mapping[F.col("raw_status")]
    # )
# 不能直接把 Python 字典套在 F.col 上做映射（比如 F.map_dict() 这种写法不存在）。
# 根本原因：F.col("severity") 是一个 JVM 内部的列表达式，而 Python 字典是 Driver 端（你的笔记本电脑） 的本地对象。Spark 的分布式集群不认识你的 Python 字典，所以不能直接把它放进 withColumn 里进行计算。

#法2 通过遍历字典一遍遍循环col这个列表
    # 核心技巧：用循环动态构建 when 链
    # 初始条件为 F.col("severity") 自身，然后不断叠加 when
    # mapping_expr = F.col("raw_status")  # 占位
    # for key, value in dict_mapping.items():
    #     mapping_expr = mapping_expr.when(F.col("raw_status") == key, value)

    # 取出第一项作为起始
    items = list(dict_mapping.items())
    first_key, first_val = items[0]
    mapping_expr = F.when(F.col("raw_status") == first_key, first_val)

    # 循环剩余项，追加 .when()
    for key, val in items[1:]:
        mapping_expr = mapping_expr.when(F.col("raw_status") == key, val)


    # 处理不存在的值（如果不在字典里，设为 -1 或保持原样）
    #mapping_expr = mapping_expr.otherwise(-1) #保持NULL

    # 应用到 withColumn
    result_df2 = issue.withColumn("std_status", mapping_expr)


#法3 通过遍历字典一遍遍循环col这个列表

    # 1. 把 Python 字典拍扁成列表，传入 createMap
    # createMap 接收 [key1, value1, key2, value2, ...]
    map_col = F.create_map([F.lit(k) for pair in dict_mapping.items() for k in pair])

    # 2. 用下标 [] 或 F.getField() 根据列值取映射结果
    # 注意：如果键不存在，返回 null
    result_df3 = issue.withColumn(
        "std_status", 
        map_col[F.col("raw_status")]  #过时写法 map_col.getItem(F.col("raw_status")) 
    )
    #空值转换
    # result_df3 = result_df3.withColumn(
    #     "std_status", 
    #     F.coalesce(F.col("std_status"), F.lit(-1)) #类似于NVL
    # lit是把 Python 数值/字符串变成 Spark 里的常量列
    # )

    return result_df
    # TODO: 你来实现，返回带 std_status 列的 DataFrame

    raise NotImplementedError("实现 solve()：用 when/otherwise 生成 std_status")

# 感官法一 略>= 法三 >> 法二
if __name__ == "__main__":
    spark = get_spark("ex02")
    df = solve(spark)
    df.groupBy("std_status").count().orderBy("std_status").show()
    spark.stop()
