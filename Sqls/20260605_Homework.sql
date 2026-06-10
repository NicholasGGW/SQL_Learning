-- oracle 包练习题要求

-- 0.从EMP复制一张EMP_0918.
CREATE TABLE EMP_0918 AS SELECT * FROM EMP;

-- 1.创建一个名为 HR_PACKAGE 的包，在包中包含以下内容：
CREATE OR REPLACE PACKAGE HR_PACKAGE AS


-- 1)自定义函数
-- calculate_total_salary 函数：
-- 功能：根据部门编号计算该部门所有员工的总工资（包括基本工资 SAL 和奖金 COMM，奖金为 NULL 时按 0 计算）。
-- 参数：p_deptno，部门编号，类型为 EMP_0918.DEPTNO%TYPE。
-- 返回值：该部门员工的总工资，类型为 NUMBER。
  -- 声明函数
FUNCTION calculate_total_salary(p_deptno EMP_0918.DEPTNO%TYPE)RETURN NUMBER;

-- 2)存储过程
-- a.increase_salary 存储过程：
-- 功能：给指定部门的员工按一定比例提高工资。
-- 参数：
-- p_deptno：部门编号，类型为 EMP_0918.DEPTNO%TYPE。
-- p_increase_rate：工资提高比例，类型为 NUMBER，默认值为 0.1（即 10%）。
  -- 声明存储过程
PROCEDURE increase_salary(p_deptno IN EMP_0918.DEPTNO%TYPE, p_increase_rate IN NUMBER DEFAULT 0.1);


-- b.transfer_EMP_0918loyee 存储过程：
-- 功能：将一名员工从一个部门调到另一个部门。
-- 参数：
-- p_EMP_0918no：员工编号，类型为 EMP_0918.EMPNO%TYPE。
-- p_old_deptno：原部门编号，类型为 EMP_0918.DEPTNO%TYPE。
-- p_new_deptno：新部门编号，类型为 EMP_0918.DEPTNO%TYPE。
PROCEDURE transfer_employee(p_empno IN EMP_0918.EMPNO%TYPE, p_old_deptno IN EMP_0918.DEPTNO%TYPE, p_new_deptno IN EMP_0918.DEPTNO%TYPE);
END HR_PACKAGE;



CREATE OR REPLACE PACKAGE BODY HR_PACKAGE AS
    FUNCTION calculate_total_salary(
        p_deptno EMP_0918.DEPTNO%TYPE
    ) RETURN NUMBER IS
        TOTAL_SAL NUMBER;
    BEGIN
        SELECT sum(NVL(SAL, 0) + NVL(COMM, 0))
        INTO TOTAL_SAL
        FROM EMP_0918
        WHERE DEPTNO = P_DEPTNO;

        RETURN NVL(TOTAL_SAL, 0);
    END CALCULATE_TOTAL_SALARY;


    PROCEDURE increase_salary( p_deptno IN EMP_0918.DEPTNO%TYPE, p_increase_rate IN NUMBER DEFAULT 0.1) 
    IS
    BEGIN
        UPDATE EMP_0918
        SET SAL = SAL * (1 + P_INCREASE_RATE)
        WHERE DEPTNO = P_DEPTNO;
    END INCREASE_SALARY;

    PROCEDURE transfer_employee(p_empno IN EMP_0918.EMPNO%TYPE, p_old_deptno IN EMP_0918.DEPTNO%TYPE, p_new_deptno IN EMP_0918.DEPTNO%TYPE) 
    IS
    BEGIN
        UPDATE EMP_0918
        SET DEPTNO = P_NEW_DEPTNO
        WHERE
            EMPNO = P_EMPNO
            AND DEPTNO = P_OLD_DEPTNO;
    END TRANSFER_EMPLOYEE;

END HR_PACKAGE;


-- 2.创建一个触发器

-- 1).check_salary_grade 触发器：
-- 薪资变化日志表,
-- id(自增序列)，EMPno,old_sal,new_sal,old_sal_grade,new_sal_grade,up_date
-- 触发时机：在 EMP_0918 表的 SAL 字段更新后触发。
-- 功能：记录员工工资和工资等级的变化，要求往薪资变化日志表里插入一条记录




CREATE SEQUENCE SEQ_SAL_CHANGE_LOG START WITH 1 INCREMENT BY 1;

CREATE TABLE SAL_CHANGE_LOG (
    ID NUMBER PRIMARY KEY,
    EMPNO NUMBER(4),
    OLD_SAL NUMBER(7, 2),
    NEW_SAL NUMBER(7, 2),
    OLD_SAL_GRADE NUMBER,
    NEW_SAL_GRADE NUMBER,
    UP_DATE DATE
);

CREATE OR REPLACE TRIGGER CHECK_SALARY_GRADE
AFTER UPDATE OF SAL ON EMP_0918
FOR EACH ROW
DECLARE
    V_OLD_GRADE NUMBER;
    V_NEW_GRADE NUMBER;
BEGIN
    BEGIN
        SELECT GRADE INTO V_OLD_GRADE
        FROM SALGRADE
        WHERE :OLD.SAL BETWEEN LOSAL AND HISAL;
    END;

    BEGIN
        SELECT GRADE INTO V_NEW_GRADE
        FROM SALGRADE
        WHERE :NEW.SAL BETWEEN LOSAL AND HISAL;
    END;

    INSERT INTO SAL_CHANGE_LOG (
        ID, EMPNO, OLD_SAL, NEW_SAL, OLD_SAL_GRADE, NEW_SAL_GRADE, UP_DATE
    ) VALUES (
        SEQ_SAL_CHANGE_LOG.NEXTVAL,
        :NEW.EMPNO,
        :OLD.SAL,
        :NEW.SAL,
        V_OLD_GRADE,
        V_NEW_GRADE,
        SYSDATE
    );
END;

-- 2).check_EMP_0918no_deptno 触发器：
-- 触发时机：在 EMP_0918 表的 deptno 字段更新后触发。
-- 功能：记录员工工号，原部门，新部门

CREATE SEQUENCE SEQ_DEPT_CHANGE_LOG START WITH 1 INCREMENT BY 1;

CREATE TABLE DEPT_CHANGE_LOG (
    ID NUMBER PRIMARY KEY,
    EMPNO NUMBER(4),
    OLD_DEPTNO NUMBER(2),
    NEW_DEPTNO NUMBER(2),
    UP_DATE DATE
);

CREATE OR REPLACE TRIGGER CHECK_EMPNO_DEPTNO
AFTER UPDATE OF DEPTNO ON EMP_0918
FOR EACH ROW
BEGIN
    INSERT INTO DEPT_CHANGE_LOG (
        ID, EMPNO, OLD_DEPTNO, NEW_DEPTNO, UP_DATE
    ) VALUES (
        SEQ_DEPT_CHANGE_LOG.NEXTVAL,
        :NEW.EMPNO,
        :OLD.DEPTNO,
        :NEW.DEPTNO,
        SYSDATE
    );
END;