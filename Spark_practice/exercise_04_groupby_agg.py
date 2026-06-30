# -*- coding: utf-8 -*-
"""
习题 04 — 分组聚合（DWS 雏形）
对应项目：dws_dept_issue.py 的"按部门聚合问题单"。

------------------------------ 要求 ------------------------------
输入：ods_issue_ticket.csv
任务：按 dept_code 分组，统计每个部门的问题单数，列名为 issue_cnt。
  · 输出两列：dept_code, issue_cnt
  · 按 issue_cnt 降序排列

pandas 对照：
    out = (df.groupby("dept_code").size()
             .reset_index(name="issue_cnt")
             .sort_values("issue_cnt", ascending=False))

Spark 关键点：
  · df.groupBy("dept_code").agg(F.count("*").alias("issue_cnt"))
  · 排序 df.orderBy(F.col("issue_cnt").desc())
  · 体会：groupBy 会触发 shuffle（数据按 key 重分区），是分布式聚合的核心

进阶（可选）：再加一列 avg(suspend_hours) 看看 F.avg 怎么用。

提示算子：df.groupBy, F.count, df.orderBy, F.desc
自检：python check.py 04
-----------------------------------------------------------------
"""
from pyspark.sql import DataFrame, functions as F
from _utils import get_spark, read


def solve(spark) -> DataFrame:
    issue = read(spark, "ods_issue_ticket.csv")
    # TODO: 你来实现，返回 dept_code, issue_cnt 两列并按 issue_cnt 降序
    raise NotImplementedError("实现 solve()：groupBy 部门 count 并降序")


if __name__ == "__main__":
    spark = get_spark("ex04")
    df = solve(spark)
    df.show(truncate=False)
    spark.stop()
