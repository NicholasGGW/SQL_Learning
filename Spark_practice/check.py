# -*- coding: utf-8 -*-
"""
习题自检器 —— 跑你写的 solve()，对照期望结果输出 PASS/FAIL。
本文件只有"期望的最终数字"，不含任何实现写法，放心：看了也不会得到答案。

用法：
    python check.py 01      # 检查习题 01
    python check.py all     # 检查全部
"""
import sys
from pyspark.sql import functions as F
from _utils import get_spark

# ---- 期望值（由确定性 mock 数据算出的"标准答案的结果"，非实现）----
GOLDEN = {
    "01": {"rows": 56, "cols": {"issue_id", "dept_code", "severity", "raw_status"}},
    "02": {"total": 200, "resolved": 29, "reopened": 29,
           "enum": {"open", "in_progress", "resolved", "closed", "rejected", "suspended", "reopened"}},
    "03": {"matched": 200, "distinct_std": 4},
    "04": {"groups": 4, "max": 56, "top_dept": "D003"},
    "05": {"total": 200, "dup": 160, "primary": 40},
}

GREEN, RED, RESET = "\033[92m", "\033[91m", "\033[0m"


def ok(msg):  print(f"{GREEN}  PASS{RESET} {msg}")
def bad(msg): print(f"{RED}  FAIL{RESET} {msg}")


def check_01(spark):
    from exercise_01_pandas_to_spark import solve
    df = solve(spark)
    g = GOLDEN["01"]
    passed = True
    if set(df.columns) == g["cols"]:
        ok(f"列正确 {sorted(g['cols'])}")
    else:
        bad(f"列应为 {sorted(g['cols'])}，实际 {sorted(df.columns)}"); passed = False
    n = df.count()
    if n == g["rows"]:
        ok(f"行数 = {n}")
    else:
        bad(f"行数应为 {g['rows']}，实际 {n}"); passed = False
    return passed


def check_02(spark):
    from exercise_02_when_mapping import solve
    df = solve(spark)
    g = GOLDEN["02"]
    passed = True
    if "std_status" not in df.columns:
        bad("缺少 std_status 列"); return False
    if df.count() == g["total"]:
        ok(f"总行数 = {g['total']}（未丢行）")
    else:
        bad(f"总行数应为 {g['total']}，实际 {df.count()}"); passed = False
    vals = {r["std_status"] for r in df.select("std_status").distinct().collect()}
    if vals == g["enum"]:
        ok("std_status 枚举值正确")
    else:
        bad(f"std_status 枚举应为 {g['enum']}，实际 {vals}"); passed = False
    cnt = {r["std_status"]: r["c"] for r in
           df.groupBy("std_status").agg(F.count("*").alias("c")).collect()}
    for k in ("resolved", "reopened"):
        if cnt.get(k) == g[k]:
            ok(f"{k} 计数 = {g[k]}")
        else:
            bad(f"{k} 应为 {g[k]}，实际 {cnt.get(k)}"); passed = False
    return passed


def check_03(spark):
    from exercise_03_join_dim import solve
    df = solve(spark)
    g = GOLDEN["03"]
    passed = True
    if "std_dept_code" not in df.columns:
        bad("缺少 std_dept_code 列"); return False
    n = df.filter(F.col("std_dept_code").isNotNull()).count()
    if n == g["matched"]:
        ok(f"匹配行数 = {n}")
    else:
        bad(f"匹配行数应为 {g['matched']}，实际 {n}"); passed = False
    d = df.select("std_dept_code").distinct().count()
    if d == g["distinct_std"]:
        ok(f"统一部门数 = {d}")
    else:
        bad(f"统一部门数应为 {g['distinct_std']}，实际 {d}"); passed = False
    return passed


def check_04(spark):
    from exercise_04_groupby_agg import solve
    df = solve(spark)
    g = GOLDEN["04"]
    passed = True
    rows = df.collect()
    if len(rows) == g["groups"]:
        ok(f"分组数 = {len(rows)}")
    else:
        bad(f"分组数应为 {g['groups']}，实际 {len(rows)}"); passed = False
    if "issue_cnt" not in df.columns:
        bad("缺少 issue_cnt 列"); return False
    top = rows[0]
    if top["issue_cnt"] == g["max"] and top["dept_code"] == g["top_dept"]:
        ok(f"降序正确，Top: {top['dept_code']}={top['issue_cnt']}")
    else:
        bad(f"Top 应为 {g['top_dept']}={g['max']}，实际 {top['dept_code']}={top['issue_cnt']}（注意降序）"); passed = False
    return passed


def check_05(spark):
    from exercise_05_window import solve
    df = solve(spark)
    g = GOLDEN["05"]
    passed = True
    for c in ("rn", "is_duplicate"):
        if c not in df.columns:
            bad(f"缺少 {c} 列"); return False
    if df.count() == g["total"]:
        ok(f"总行数 = {g['total']}（窗口不压缩行）")
    else:
        bad(f"总行数应为 {g['total']}，实际 {df.count()}"); passed = False
    dup = df.filter(F.col("is_duplicate") == 1).count()
    if dup == g["dup"]:
        ok(f"重复单数 = {dup}")
    else:
        bad(f"重复单数应为 {g['dup']}，实际 {dup}"); passed = False
    primary = df.filter(F.col("rn") == 1).count()
    if primary == g["primary"]:
        ok(f"主单数 = {primary}")
    else:
        bad(f"主单数应为 {g['primary']}，实际 {primary}"); passed = False
    return passed


CHECKS = {"01": check_01, "02": check_02, "03": check_03, "04": check_04, "05": check_05}


def run(which):
    spark = get_spark(f"check_{which}")
    spark.sparkContext.setLogLevel("ERROR")
    try:
        print(f"\n=== 习题 {which} ===")
        passed = CHECKS[which](spark)
        print(f"{GREEN}✅ 习题 {which} 全部通过{RESET}" if passed
              else f"{RED}❌ 习题 {which} 未通过，按提示改{RESET}")
        return passed
    except NotImplementedError as e:
        print(f"{RED}  还没实现：{e}{RESET}")
        return False
    finally:
        spark.stop()


if __name__ == "__main__":
    arg = sys.argv[1] if len(sys.argv) > 1 else "all"
    targets = list(CHECKS) if arg == "all" else [arg.zfill(2)]
    results = {t: run(t) for t in targets}
    print("\n==== 汇总 ====")
    for t, p in results.items():
        print(f"  习题 {t}: {'PASS' if p else 'FAIL'}")
