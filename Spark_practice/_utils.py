# -*- coding: utf-8 -*-
"""练习用的小工具（已写好，直接 import 用）。读取本目录 data/ 下的 CSV。
   spark_practice/ 自包含，与项目 etl/、mock_data/ 完全解耦，可单独拷走运行。"""
import os
from pyspark.sql import SparkSession, DataFrame

DATA_DIR = os.path.join(os.path.dirname(__file__), "data")


def get_spark(app="practice") -> SparkSession:
    return (SparkSession.builder.appName(app).master("local[*]")
            .config("spark.sql.shuffle.partitions", "4")
            .config("spark.ui.showConsoleProgress", "false")
            .getOrCreate())


def read(spark: SparkSession, name: str) -> DataFrame:
    return (spark.read.option("header", "true").option("inferSchema", "true")
            .csv(os.path.join(DATA_DIR, name)))
