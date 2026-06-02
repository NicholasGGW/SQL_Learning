
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY/MM/DD';
SELECT * FROM DATE_LIST
--1 从字符串 'AHDSADVBDS' 从第一个位置开始找，第一次出现 D 的位置;
SELECT INSTR('AHDSADVBDS', 'D') FROM DUAL;

--2 从字符串 'AHDSADVBDS' 从第4个位置开始找，第2次出现 D 的位置;
SELECT INSTR('AHDSADVBDS', 'D', 4, 2) FROM DUAL;

--3 从 '15min' 这个字符串 得到 15;
SELECT REPLACE('15min', 'min', '') FROM DUAL;
SELECT SUBSTR('15min', 1, 2) FROM DUAL;

--5 将字符串'###abcdefg***h'截取成'abcdefg';
SELECT SUBSTR('###abcdefg***h', 4, 7) FROM DUAL;

--6 将字符串 'dddasrgasty' 截取成 'asrg';
SELECT SUBSTR('dddasrgasty', 4, 4) FROM DUAL;

--7 将字符串'###abcdefg***h' 截取成'h';
SELECT SUBSTR('###abcdefg***h', -1) FROM DUAL;

--8 将字符串 'SDNDJDAAE' 截取成'AAE';
SELECT SUBSTR('SDNDJDAAE', -3) FROM DUAL;

--9 将字符串 'SDNDJDAAE' 截取成'DND';
SELECT SUBSTR('SDNDJDAAE', 2, 3) FROM DUAL;

--10 使用函数找出2021年4月15号的下一个月的最后一天
SELECT LAST_DAY(ADD_MONTHS(TO_DATE('20210415', 'YYYYMMDD'), 1)) FROM DUAL;

--11 使用函数找出2021年4月15号的所在季度的第一天
SELECT TRUNC(TO_DATE('20210415', 'YYYYMMDD'), 'Q') FROM DUAL;

--12 使用函数找出2021年4月15号的所在是星期几
SELECT TO_CHAR(TO_DATE('20210415', 'YYYYMMDD'), 'DAY') FROM DUAL;

--13 使用函数找出2021年4月15号三个月之前是哪一天
SELECT ADD_MONTHS(TO_DATE('20210415', 'YYYYMMDD'), -3) FROM DUAL;

--14 为员工表中的姓名做脱敏，保留两位字母，其余字母都变为*
--S***H 
SELECT RPAD(SUBSTR(ENAME, 1, 1), LENGTH(ENAME) - 1, '*') || SUBSTR(ENAME, -1) AS ENAME_NEW 
FROM EMP;

--SM***
SELECT RPAD(SUBSTR(ENAME, 1, 2), LENGTH(ENAME), '*') AS ENAME_NEW 
FROM EMP;














