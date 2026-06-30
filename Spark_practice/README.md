# Spark 学习沙箱

5 道分级习题，从你熟悉的 pandas 切入，逐步过渡到 Spark 的核心算子。
每题都对应项目里一段真实的 ETL 清洗逻辑 —— 练完就能回去填 `etl/` 的 TODO。

**答案不在任何文件里**。`check.py` 只存"期望的结果数字"，不含写法，看了也拿不到答案。

> 本目录**自包含**：数据在 `data/`，工具在 `_utils.py`，不依赖项目其它任何代码或数据。
> 整个 `spark_practice/` 可以单独拷到别处运行（只要装了 JDK + pyspark）。

---

## 准备

```bash
sudo apt install openjdk-17-jdk
java -version          # 确认有 JDK 8/11/17（Spark 跑在 JVM 上，必须有 Java）


# 安装 uv（如果还没有）
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env


# 进项目根目录，建虚拟环境（顺便指定 Python 版本，pyspark 3.5 建议 3.11）
uv venv --python 3.11
source .venv/bin/activate

# 装依赖（用现成的 requirements.txt）
uv pip install -r requirements.txt --index-url https://pypi.tuna.tsinghua.edu.cn/simple

uv pip install -r requirements.txt
# 或单独装： uv pip install pyspark

# 跑脚本（激活了 venv 直接 python 即可，或用 uv run）
uv run python exercise_01_pandas_to_spark.py

# 调试
Ctrl + Shift + P
→ Python: Select Interpreter

# 纯pip
pip install pyspark    # 或 uv pip install pyspark
```



## 怎么做每一题

1. 打开 `exercise_0X_*.py`，看顶部注释的**要求**和 **pandas 对照**
2. 在 `solve()` 里把 `raise NotImplementedError(...)` 删掉，写你的实现
3. 单独运行看输出：`python exercise_01_pandas_to_spark.py`
4. 自检：`python check.py 01`（绿色 PASS / 红色 FAIL，FAIL 会告诉你哪不对）

## 习题清单（难度递增）

| 题 | 主题 | Spark 要点 | 对应项目 |
|---|---|---|---|
| 01 | 读取 + 选列 + 过滤 | `select` / `filter` / 不可变 / lazy | clean_issue 读 ODS |
| 02 | 条件映射 | `when/otherwise` / `withColumn` | 问题单状态标准化 |
| 03 | join 维表 | `broadcast join` | 部门编码统一 |
| 04 | 分组聚合 | `groupBy/agg` / shuffle | dws 部门聚合 |
| 05 | 窗口函数 | `Window` / `row_number` | 重复单识别 |

## 建议节奏

- 一次一题，先自己想"pandas 里我会怎么做"，再查 Spark 对应算子怎么写。
- 卡住了：先看顶部"提示算子"，再去查 PySpark 官方文档里那几个函数的签名。
- 全部 PASS 后，回到项目 `etl/` 把对应的 transform 填上，跑 `./scripts/run_etl.sh`。
- 想让我 review / 讲解某题思路，或要更进阶的题（如 MinHash LSH 判重、多表关联），随时说。

---

## 常见报错

- `JAVA_HOME is not set` / `java: command not found` → 装 JDK 或设 `JAVA_HOME`
- `No module named pyspark` → `pip install -r ../requirements.txt`
- 中文显示乱码 → 确认终端 UTF-8；数据本身是 UTF-8 编码
