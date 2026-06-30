# -*- coding: utf-8 -*-
"""
习题 05 — 窗口函数：识别重复提单（最难，慢慢来）
对应项目：clean_issue.py 的"重复单识别"（简化版，不用 LSH，用 (模块,标题) 完全相同来判重）。

------------------------------ 要求 ------------------------------
输入：ods_issue_ticket.csv
背景：同一个 (module_code, title) 可能被多个人重复提单。我们要把每组里
      最早创建的那条当作"主单"，其余标为重复单。

任务：返回带两列标记的 DataFrame：
  · rn          : 组内按 create_time 升序的序号（1,2,3...）
  · is_duplicate: rn>1 则 1（重复单），rn==1 则 0（主单）
  保留原有列 + 这两列。

pandas 对照（pandas 用 groupby+cumcount，Spark 用窗口函数）：
    df["rn"] = df.sort_values("create_time").groupby(["module_code","title"]).cumcount()+1
    df["is_duplicate"] = (df["rn"]>1).astype(int)

Spark 关键点（窗口函数三要素）：
  from pyspark.sql.window import Window
  w = Window.partitionBy("module_code","title").orderBy("create_time")
  · 用 F.row_number().over(w) 生成组内序号
  · 再用 when 把 rn>1 标成 1
  · 体会：窗口函数不会像 groupBy 那样把行数压缩，每行都保留并附加计算列

提示算子：Window.partitionBy().orderBy(), F.row_number().over(w), F.when
自检：python check.py 05
-----------------------------------------------------------------
"""
from pyspark.sql import DataFrame, functions as F
from pyspark.sql.window import Window
from _utils import get_spark, read


def solve(spark) -> DataFrame:
    issue = read(spark, "ods_issue_ticket.csv")
    # TODO: 你来实现，返回带 rn 和 is_duplicate 两列的 DataFrame
    raise NotImplementedError("实现 solve()：用窗口函数 row_number 标记重复单")


if __name__ == "__main__":
    spark = get_spark("ex05")
    df = solve(spark)
    df.select("module_code", "title", "create_time", "rn", "is_duplicate") \
      .orderBy("module_code", "title", "rn").show(20, truncate=False)
    print("重复单数 =", df.filter(F.col("is_duplicate") == 1).count())
    spark.stop()
