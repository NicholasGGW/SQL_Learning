import pandas as pd
import numpy as np
import sqlite3

def run_demo():
    print("="*60)
    print("🚀 数据分析面试实操演示：Python (Pandas) 清洗 + SQL 核心进阶")
    print("="*60)

    # ---------------------------------------------------------
    # 1. 构造“脏数据” (Dirty Data)
    # ---------------------------------------------------------
    print("\n[步骤 1]: 生成带有问题的初始脏数据...")
    
    dirty_data = {
        'user_id': [101, 102, 102, 103, 104, 105, np.nan, 106, 107], # 存在重复和缺失的 user_id
        'age': ['25', '28', '28', '35', '200', '22', '30', '48', '28'], # 数据类型错误(字符串)，且有异常值(200岁)
        'department': ['Sales', 'Tech', 'Tech', 'Sales', 'HR', np.nan, 'HR', 'Support', 'Marketing'], # 存在缺失部门
        'salary': [5000, 8000, 8000, 5500, 4000, np.nan, 4500, 6000, 7000] # 存在缺失和重复薪水
    }
    
    df_dirty = pd.DataFrame(dirty_data)
    print("\n--- 原始脏数据 ---")
    print(df_dirty)


    # ---------------------------------------------------------
    # 2. 使用 Pandas 进行数据清洗 (Data Cleaning)
    # ---------------------------------------------------------
    print("\n[步骤 2]: 使用 Python Pandas 进行数据清洗...")
    
    # a. 复制一份数据避免修改原数据
    df_clean = df_dirty.copy()
    
    # b. 删除包含缺失关键字段(user_id)的行
    print("  -> 清洗动作: 删除 user_id 为空的行")
    df_clean.dropna(subset=['user_id'], inplace=True)
    
    # c. 去除完全重复的行 (user_id 102重复了)
    print("  -> 清洗动作: 按照 user_id 去重")
    df_clean.drop_duplicates(subset=['user_id'], keep='first', inplace=True)
    
    # d. 数据类型转换与异常值处理
    print("  -> 清洗动作: 将 age 转换为数字，并将年龄大于 100 岁的视为异常，置为空值后用均值填充")
    df_clean['age'] = pd.to_numeric(df_clean['age'])
    df_clean.loc[df_clean['age'] > 100, 'age'] = np.nan
    age_mean = df_clean['age'].mean()
    df_clean['age'] = df_clean['age'].fillna(age_mean).round().astype(int)
    
    # e. 填充部门和薪水的缺失值
    print("  -> 清洗动作: 部门为空的填充为 'Unknown'，薪水为空的填充为该列中位数")
    df_clean['department'] = df_clean['department'].fillna('Unknown')
    salary_median = df_clean['salary'].median()
    df_clean['salary'] = df_clean['salary'].fillna(salary_median)
    
    print("\n--- 清洗后的干净数据 ---")
    print(df_clean)


    # ---------------------------------------------------------
    # 3. 将清洗后的数据导入 SQLite，演示高频 SQL 面试题
    # ---------------------------------------------------------
    print("\n[步骤 3]: 将清洗后的数据加载到数据库，执行核心 SQL 演练...")
    
    # 在内存中创建一个轻量级数据库连接
    conn = sqlite3.connect(':memory:')
    
    # 将 Pandas DataFrame 写入名为 'employees' 的 SQL 表
    df_clean.to_sql('employees', conn, index=False, if_exists='replace')
    
    # 为了演示 JOIN，我们再创建一张部门详细信息表
    dept_data = pd.DataFrame({
        'dept_name': ['Sales', 'Tech', 'HR', 'Support'],
        'location': ['Beijing', 'Shanghai', 'Shenzhen', 'Guangzhou']
    })
    dept_data.to_sql('departments', conn, index=False, if_exists='replace')

    # 定义一个运行 SQL 的辅助函数
    def run_sql(query, description):
        print(f"\n--- {description} ---")
        print(f"SQL语句:\n{query}")
        result = pd.read_sql_query(query, conn)
        print("查询结果:")
        print(result)

    # --- SQL 演练 1: 基础查询 (简单过滤) ---
    sql_basic = """
        SELECT user_id, department, salary 
        FROM employees 
        WHERE salary > 6000;
    """
    run_sql(sql_basic, "SQL考点 1: 基础 WHERE 过滤 (查询薪水大于6000的员工)")


    # --- SQL 演练 2: 分组聚合 (GROUP BY) ---
    sql_groupby = """
        SELECT department, COUNT(*) as emp_count, AVG(salary) as avg_salary 
        FROM employees 
        GROUP BY department;
    """
    sql_groupby = """
        SELECT age, COUNT(*) as emp_count, SUM(salary) as total_salary 
        FROM employees 
        GROUP BY age;
    """
    run_sql(sql_groupby, "SQL考点 2: GROUP BY 分组聚合 (查询不同年龄段的员工数和总薪水)")


    # --- SQL 演练 3: 多表关联 (JOIN) ---
    sql_join = """
        SELECT e.user_id, e.department, d.location, e.salary
        FROM employees e
        LEFT JOIN departments d ON e.department = d.dept_name;
    """
    run_sql(sql_join, "SQL考点 3: LEFT JOIN 左连接 (关联部门表获取地点信息)")


    # --- SQL 演练 4: 窗口函数 (Window Function) - 面试杀手锏 ---
    sql_window = """
        SELECT user_id, department, age,
               ROW_NUMBER() OVER(PARTITION BY department ORDER BY age DESC) as age_rank
        FROM employees;
    """
    run_sql(sql_window, "SQL考点 4: 窗口函数 ROW_NUMBER (计算每个部门内的年龄排名)")

    print("\n" + "="*60)
    print("✅ 实操演示运行完毕。预祝面试成功！")
    print("="*60)
    
    # 关闭连接
    conn.close()

if __name__ == "__main__":
    run_demo()
