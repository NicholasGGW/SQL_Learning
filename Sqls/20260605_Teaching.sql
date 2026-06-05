
--那个sysdate-1=s.update肯定不精确

--位置传参：按照顺序
--可以通过指定传参（指向赋值）进行乱序传参


--默认值传参

--如果不传参，使用默认值
--传参则替换


--因为有默认值，所以无默认值的单独传参，就得用指向赋值




--没有指定传参的变量也可以传参


--MERGE INTO示例
BEGIN
  MERGE INTO EMP_TARGET T1 --目标表
  USING (SELECT * FROM EMP_SOURCE A WHERE A.UP_DATE = TRUNC(SYSDATE-1,'DD')) S1
  --通过SQL查询要更新的数据
  ON (T1.EMPNO = S1.EMPNO) --匹配条件，一般是使用主键作为条件
  WHEN MATCHED THEN UPDATE SET T1.ENAME     = S1.ENAME,
                               T1.JOB       = S1.JOB,
                               T1.MGR       = S1.MGR,
                               --T1.HIREDATE  = S1.HIREDATE,--入职日期不需要同步
                               T1.SAL       = S1.SAL,
                               T1.BONUS      = S1.BONUS,
                               T1.DEPTNO    = S1.DEPTNO,
                               T1.ETL_DATE  = TRUNC(SYSDATE,'DD') ----最后一个更新的字段不能有逗号
  WHEN NOT MATCHED THEN INSERT(EMPNO     ,
                               ENAME     ,
                               JOB       ,
                               MGR       ,
                               HIREDATE  ,
                               SAL       ,
                               BONUS      ,
                               DEPTNO    ,
                               ETL_DATE ) 
                          VALUES (S1.EMPNO ,
                                  S1.ENAME,
                                  S1.JOB,
                                  S1.MGR,
                                  S1.HIREDATE,
                                  S1.SAL,
                                  S1.BONUS,
                                  S1.DEPTNO,
                                  TRUNC(SYSDATE,'DD') );
  COMMIT;                                
END;   


--11点02分
--练习：部门表的增量更新
-- 1. 创建原始 dept 表（源表）
select * from dept;
drop TABLE dept_source;
CREATE TABLE dept_source as
select deptno,dname,loc,sysdate-2  as up_date
from dept;

--2.创建目标表：
DROP TABLE dept_target;
CREATE TABLE dept_target as
select deptno,dname,loc,sysdate-2  as up_date
from dept;

--3.原表昨日更新：
update dept_source set loc='上海',up_date=sysdate-1  where deptno=40;
insert into dept_source values(50,'testing','深圳',sysdate-1);

select * from dept_source;
select * from dept_target;

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD';
SELECT * FROM dept_source A WHERE TRUNC(A.up_date,'DD') = TRUNC(SYSDATE,'DD') -2 ;
--4.编写merge into增量更新   

BEGIN
  MERGE INTO dept_target T1 --目标表
  USING (SELECT * FROM dept_source A WHERE TRUNC(A.up_date,'DD') = TRUNC(SYSDATE,'DD') -1) S1
  --通过SQL查询要更新的数据
  ON (T1.DEPTNO = S1.DEPTNO) --匹配条件，一般是使用主键作为条件
  WHEN MATCHED THEN UPDATE SET T1.DNAME     = S1.DNAME,
                               T1.LOC       = S1.LOC,
                               T1.UP_DATE  = TRUNC(SYSDATE,'DD')
  WHEN NOT MATCHED THEN INSERT (DEPTNO,
                               DNAME,
                               LOC,
                               UP_DATE) VALUES
                               ( S1.DEPTNO,
                                 S1.DNAME,
                                 S1.LOC,
                                TRUNC(SYSDATE,'DD') );
  COMMIT;                                
END;   



--ROLLBACK可以回滚上次 COMMIT 之后的所有 DML，但是对TRUNCATE（隐式COMMIT），以及COMMIT的行为不行，



DECLARE
 V_SAL NUMBER;
BEGIN 
  SELECT T.JOB
  INTO V_SAL
  FROM EMP T 
  WHERE T.EMPNO = 7369;
  --其他错误
  ----捕获指定异常 
  
  SELECT T.SAL
  INTO V_SAL
  FROM EMP T 
  WHERE T.EMPNO = 567;
  --SELECT INTO没有找到数据的异常*/ 

  
  SELECT T.SAL
  INTO V_SAL
  FROM EMP T 
  WHERE T.DEPTNO = 10;
  --SELECT INTO行数过多*/

  EXCEPTION WHEN Too_many_rows THEN --SELECT INTO返回了多行数据
      DBMS_OUTPUT.put_line('错误AA');
    
    WHEN NO_DATA_FOUND THEN --SELECT INTO没有找到数据的异常
      DBMS_OUTPUT.put_line('错误BB'); 
    
    WHEN OTHERS THEN 
      DBMS_OUTPUT.put_line(SQLERRM);
END;

--11点46分
--3、自定义异常
--当代码满足某一种条件的时候，代码本身没有报错，但是代码还是会跳转到异常处理逻辑
--也可以为是一种跳转机制。

DECLARE
  V_EXCEPTION EXCEPTION;  ---异常类型的变量
  I_NO  NUMBER;
BEGIN 
  I_NO := &请输入一个数字;
  
  IF I_NO = 1 THEN 
    
    RAISE V_EXCEPTION;
    --RAISE 这个关键字是跳转到异常
    
  END IF;
  
  DBMS_OUTPUT.put_line('I_NO等于其他，正常！');--如果跳转了异常，这一行代码不会被执行
  
  EXCEPTION WHEN V_EXCEPTION THEN  --当符合条件后执行了前面的 RAISE就会跳转到这里。
     DBMS_OUTPUT.put_line('I_NO 不允许等于1');

END;