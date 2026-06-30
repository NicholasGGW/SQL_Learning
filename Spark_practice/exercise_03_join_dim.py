# -*- coding: utf-8 -*-
"""
习题 03 — join 维表做编码统一
对应项目：clean_issue.py 的"部门编码统一"（join dim_dept_mapping）。

------------------------------ 要求 ------------------------------
输入：
  · 主表 ods_issue_ticket.csv （字段 dept_code 是问题单系统的原始部门编码）
  · 维表 dim_dept_mapping.csv  （取 source_system=='issue' 的行）
任务：给每条问题单关联出统一部门编码 std_dept_code。
  · 用 issue.dept_code = dim.source_code 做关联
  · 结果保留问题单原列 + 新增 std_dept_code
  · 用 inner join 即可（本数据所有 dept_code 都能匹配上）

pandas 对照：
    out = issue.merge(dim[dim.source_system=="issue"],
                      left_on="dept_code", right_on="source_code", how="inner")

Spark 关键点：
  · 维表很小 -> 用 F.broadcast(dim) 做 broadcast join（避免 shuffle，面试常考）
  · join 写法：issue.join(F.broadcast(dim), issue.dept_code==dim.source_code, "inner")
  · join 后两边可能有同名列，注意 select 需要的列、避免歧义

提示算子：df.join, F.broadcast, df.select
自检：python check.py 03
-----------------------------------------------------------------
"""
from pyspark.sql import DataFrame, functions as F
from _utils import get_spark, read


def solve(spark) -> DataFrame:
    issue = read(spark, "ods_issue_ticket.csv")
    dim = read(spark, "dim_dept_mapping.csv").where(F.col("source_system") == "issue")
    # TODO: 你来实现，返回带 std_dept_code 的 DataFrame
    raise NotImplementedError("实现 solve()：broadcast join 维表得到 std_dept_code")


if __name__ == "__main__":
    spark = get_spark("ex03")
    df = solve(spark)
    df.select("issue_id", "dept_code", "std_dept_code").show(10, truncate=False)
    print("行数 =", df.count())
    spark.stop()
