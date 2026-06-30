# -*- coding: utf-8 -*-
"""
习题 01 — 从 pandas 思维迁移到 Spark：读取 + 选列 + 过滤
对应项目：clean_issue.py 里读 ODS、选字段的第一步。

------------------------------ 要求 ------------------------------
输入：mock_data/ods_issue_ticket.csv （已用 read() 读好传给你）
任务：返回一个 DataFrame，满足：
  · 只保留这 4 列：issue_id, dept_code, severity, raw_status
  · 只保留 severity == '致命' 的行

pandas 里你会这么写（对照）：
    df = pd.read_csv("ods_issue_ticket.csv")
    out = df[df["severity"] == "致命"][["issue_id","dept_code","severity","raw_status"]]

Spark 的关键差异（要体会的点）：
  · Spark DataFrame 不可变：每个操作返回新 df，不能像 pandas 那样原地改
  · 过滤用 df.filter(条件) 或 df.where(条件)，列引用用 F.col("severity")
  · 选列用 df.select("a","b",...)
  · lazy：在 .show()/.count() 之前不会真正执行

提示算子：F.col, df.filter, df.select
运行查看： python exercise_01_pandas_to_spark.py
自检：     python check.py 01
-----------------------------------------------------------------
"""
from pyspark.sql import DataFrame, functions as F
from _utils import get_spark, read


def solve(spark) -> DataFrame:
    issue = read(spark, "ods_issue_ticket.csv")
    # TODO: 你来实现，返回处理后的 DataFrame
    print("请实现 solve()：选 4 列 + 过滤 severity=='致命'")
    # 因为 df.filter("severity = '致命'") 也是可以的，用字符串SQL表达式。但用 F.col 更类型安全，并且可以链式调用其他函数。

    # 链式调用
    issue.select("issue_id", "dept_code", "severity", "raw_status").filter(F.col("severity") == "致命").show()
    print(issue.count())
    
    # 链式赋值
    issue =issue.select("issue_id", "dept_code", "severity", "raw_status")
    #不触发count的话仅仅只是 惰性计算，只转化（包含旧的血缘关系 + 新的过滤逻辑），底层不会复制
    #issue.count() # 行动操作（show, count, collect）返回值为None，不能赋值给 df，否则后续操作会报错
    issue = issue.filter(F.col("severity") == "致命")
    print(issue.count())



    #issue.filter(servity == "致命")
    #issue.show()
    # 并没有立即复制数据
    return issue  # 返回处理后的 DataFrame
    raise NotImplementedError("实现 solve()：选 4 列 + 过滤 severity=='致命'")


if __name__ == "__main__":
    spark = get_spark("ex01")
    df = solve(spark)
    df.show(10, truncate=False)
    print("行数 =", df.count())
    spark.stop()
