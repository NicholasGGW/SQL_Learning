--表关联\多表查询\连接查询---------------------
--连接查询/多表关联查询：使用多张表连接起来进行查询，拿到我们要想要的结果
--分为 内连接 和 外连接

SELECT * FROM EMP;--员工表
SELECT * FROM DEPT;--部门表
SELECT * FROM SALGRADE;--工资等级表

----内连接([INNER] JOIN)----------------------------------
标准写法。语法结构：
SELECT 要查询的字段/列
FROM 表1 
    INNER JOIN 表2 ON 关联条件 AND 过滤从表条件 
    INNER JOIN 表3 ON 关联条件 AND 过滤从表条件
    INNER JOIN .............
WHERE 过滤全部表的条件;

--示例1：查询EMP表所有员工的信息，以及对应DEPT表的部门信息
SELECT *
FROM EMP
INNER JOIN DEPT
ON EMP.DEPTNO=DEPT.DEPTNO
;
--给表起别名
SELECT *
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO
;

--查看30部门的
--员工工号，姓名，工资，部门编号，部门名称，工作地点
--按照薪资降序
SELECT T1.EMPNO,
       T1.ENAME,
       T1.SAL,
       T1.DEPTNO,
       T2.DNAME,
       T2.LOC
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO
WHERE T1.DEPTNO=30
ORDER BY SAL DESC;

--从dept表复制，只复制10和20部门
CREATE TABLE DEPT_0601 AS
SELECT * FROM DEPT WHERE DEPTNO IN (10,20);

SELECT * FROM DEPT_0601;

SELECT *
FROM EMP T1
INNER JOIN DEPT_0601 T2
ON T1.DEPTNO=T2.DEPTNO
;

--这个代码返回多少行数据

SELECT *
FROM EMP T1          --14
INNER JOIN DEPT T2   --4
ON T1.DEPTNO < T2.DEPTNO
ORDER BY T1.EMPNO,T2.DEPTNO
;

--关联条件写的不准确会导致数据膨胀，
--数据膨胀 》》》》笛卡尔积
SELECT *
FROM EMP T1          --14
INNER JOIN DEPT T2   --4
ON 1 = 1
--ON T1.DEPTNO=T1.DEPTNO
ORDER BY T1.EMPNO,T2.DEPTNO
;


--示例3：在ON添加AND来增加更多的匹配条件
--查找在NEW YORK工作的员工
SELECT *
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO AND T2.LOC='NEW YORK';

SELECT *
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO 
WHERE T2.LOC='NEW YORK';

--练习1：查询工资不小于2000的员工工号、部门编号、
--部门名称、工资，按照部门名称降序
SELECT T1.EMPNO,
       T1.DEPTNO,
       T2.DNAME,
       T1.SAL
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO
WHERE SAL>=2000
ORDER BY DNAME DESC;

--练习2：查询各个工作地点的人数
SELECT T2.LOC,
       COUNT(1)
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO
GROUP BY T2.LOC;

--练习3：查询各个工作地点工资不少于2000的人数 ，
--按照人数降序
SELECT T2.LOC,
       COUNT(1) AS 人数
FROM EMP T1
INNER JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO
WHERE T1.SAL>=2000
GROUP BY T2.LOC
ORDER BY 人数 DESC;


--------------------外连接([OUTER] JOIN)-----------
分为：左[外]连接、右[外]连接、全[外]连接
CREATE TABLE EMPLEFT AS 
SELECT * FROM EMP;

UPDATE EMPLEFT SET DEPTNO = NULL WHERE DEPTNO=10;

INSERT INTO EMPLEFT(EMPNO,DEPTNO) VALUES(1111,80);

SELECT * FROM EMPLEFT;--员工表  --15条数据
SELECT * FROM DEPT;--部门表

--左外连接
--LEFT JOIN (左边的表为主表)
--EMPLEFT为主表
SELECT *
FROM EMPLEFT T1     
LEFT JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO;


--DEPT为主表
SELECT *
FROM DEPT T1
LEFT JOIN EMPLEFT T2
ON T1.DEPTNO=T2.DEPTNO;

--右外连接
--RIGHT JOIN --右边的表为主表
SELECT T2.*,T1.*
FROM DEPT T1
RIGHT JOIN EMPLEFT T2
ON T1.DEPTNO=T2.DEPTNO;


--全外连接
--FULL JOIN --返回所有数据
SELECT *
FROM EMPLEFT T1     
FULL JOIN DEPT T2
ON T1.DEPTNO=T2.DEPTNO;

--使用LEFT JOIN 解题：思考谁是主表
--练习1：结合EMP和DEPT表查询四个工作地点的人数，
--如果该地点没有员工则展示为0 
--小提示：这里涉及到聚合函数的一个小知识点
SELECT d.LOC, COUNT(e.EMPNO)
FROM DEPT d     
LEFT JOIN EMPLEFT e
ON e.DEPTNO = d.DEPTNO
GROUP BY d.LOC;


--练习2：从EMP表和DEPT表中查询
--员工号、员工姓名、工资、部门名称、工作地点，
SELECT e.EMPNO, e.ENAME, e.SAL, d.DNAME, d.LOC 
FROM EMPLEFT e     
LEFT JOIN DEPT d
ON e.DEPTNO = d.DEPTNO;


--练习3：思考如何写匹配条件，查询EMP中员工对应 SALGRADE工资表中的工资等级。
--小提示：匹配条件除了可以使用 = 也可以使用 <  >  等其他关系运算符
SELECT * FROM SALGRADE;

SELECT e.EMPNO, e.ENAME, e.SAL, s.GRADE 
FROM EMP e     
LEFT JOIN SALGRADE s
ON e.SAL <= s.HISAL AND e.SAL >= s.LOSAL;
--ON e.SAL >= s.LOSAL AND e.SAL <= s.HISAL;
ON e.SAL <= s.HISAL AND e.SAL >= s.LOSAL;
--ON e.SAL BETWEEN s.LOSAL AND s.HISAL; 
 
--在工作中尽可能使用左外关联，少右外关联。

--多表关联：查询员工信息、部门信息、工资等级
SELECT *
FROM EMP T1
LEFT JOIN DEPT T2
        ON T1.DEPTNO = T2.DEPTNO
LEFT JOIN SALGRADE T3
        ON T1.SAL BETWEEN T3.LOSAL AND T3.HISAL;


--多表关联：
--查询每个部门里面，工资不低于1000块的薪资等级分布情况
--返回：部门编号，部门名称，薪资等级，人数
--按照部门编号升序排列

SELECT d.DEPTNO, d.DNAME
FROM DEPT d

SELECT d.DEPTNO, d.DNAME, s.GRADE, COUNT(e.EMPNO)
FROM DEPT d
LEFT JOIN EMP e 
          ON d.DEPTNO = e.DEPTNO
          --ON d.DEPTNO = e.DEPTNO AND e.SAL >=1000
LEFT JOIN SALGRADE s
          ON e.SAL <= s.HISAL AND e.SAL >= s.LOSAL          
WHERE e.SAL IS NULL OR e.SAL >= 1000
GROUP BY d.deptno, d.dname, s.grade
ORDER BY d.deptno;





--练习1：建立一个新表 EMP1110 ，
--表中有三个字段：EMPID(NUMBER) 员工号 \
                --ENAME(VARCHAR2) 姓名 \
                --ESAL(NUMBER) 工资
--插入两个员工，工号、姓名、工资随便即可
CREATE TABLE EMP1110(EMPID NUMBER(4),
                     ENAME VARCHAR2(10),
                     ESAL NUMBER(3)
                     );
INSERT INTO EMP1110 VALUES(1,'张三',200);
INSERT INTO EMP1110 VALUES(2,'A',220);

--练习2：查询EMP表中20部门的员工号、员工姓名、工资
--和EMP1110合并展示。
SELECT e.empno,e.ename,e.sal FROM EMP e
UNION ALL
SELECT * FROM EMP1110

--练习3：查询EMP1110中的总工资和EMP的总工资，合并展示。
SELECT 'EMP110' AS EMP_TABLE_NAME, SUM(e2.esal) FROM EMP1110 e2
UNION ALL
SELECT 'EMP' AS EMP_TABLE_NAME, SUM(e.sal) FROM EMP e


--练习4：
--请分别查询EMP表中工资低于1000有多少人，
--1000到2000的多少人，2000到3000有多少人，3000以上的多少人,
--左闭右开，合并展示
SELECT T1.EMP_SALARY_GRADE, T1.COUNT(E.EMPNO)
FROM (SELECT 'EMP 低于1000' AS EMP_SALARY_GRADE, COUNT(e.empno) FROM EMP e WHERE e.sal < 1000 AND e.sal >= 0
UNION ALL
SELECT 'EMP 1000到2000' AS EMP_SALARY_GRADE, COUNT(e.empno) FROM EMP e WHERE e.sal < 2000 AND e.sal >= 1000
UNION ALL
SELECT 'EMP 2000到3000' AS EMP_SALARY_GRADE, COUNT(e.empno) FROM EMP e WHERE e.sal < 3000 AND e.sal >= 2000
UNION ALL
SELECT 'EMP 3000以上' AS EMP_SALARY_GRADE, COUNT(e.empno) FROM EMP e WHERE e.sal >= 3000) T1





SELECT e.empno,e.ename
FROM EMP e
WHERE e.sal > (SELECT AVG(e.sal) FROM EMP e);
