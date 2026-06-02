--1 从字符串 'AHDSADVBDS' 从第一个位置开始找，第一次出现 D 的位置;
-- 方法1：使用默认参数
SELECT INSTR('AHDSADVBDS', 'D') FROM DUAL;
-- 方法2：使用完整参数
SELECT INSTR('AHDSADVBDS', 'D', 1, 1) FROM DUAL;

--2 从字符串 'AHDSADVBDS' 从第4个位置开始找，第2次出现 D 的位置;
SELECT INSTR('AHDSADVBDS', 'D', 4, 2) FROM DUAL;

--3 从 '15min' 这个字符串 得到 15;
-- 方法1：使用REPLACE函数替换掉 'min'
SELECT REPLACE('15min', 'min', '') FROM DUAL;
-- 方法2：使用SUBSTR函数截取前两位
SELECT SUBSTR('15min', 1, 2) FROM DUAL;
-- 方法3：使用RTRIM去掉右侧的 'min' 字符，RTRIM参数为字符集，会移除所有'm'、'i'、'n'
SELECT RTRIM('15min', 'min') FROM DUAL;

--5 将字符串'###abcdefg***h'截取成'abcdefg';
-- 方法1：使用SUBSTR函数根据固定位置截取
SELECT SUBSTR('###abcdefg***h', 4, 7) FROM DUAL;
-- 方法2：结合REPLACE函数替换掉不需要的部分
SELECT REPLACE(REPLACE('###abcdefg***h', '###', ''), '***h', '') FROM DUAL;

--6 将字符串 'dddasrgasty' 截取成 'asrg';
-- 方法1：使用SUBSTR函数根据固定位置截取
SELECT SUBSTR('dddasrgasty', 4, 4) FROM DUAL;
-- 方法2：结合INSTR和SUBSTR动态截取（假设查找asrg开始位置）
SELECT SUBSTR('dddasrgasty', INSTR('dddasrgasty', 'asrg'), 4) FROM DUAL;

--7 将字符串'###abcdefg***h' 截取成'h';
-- 方法1：使用SUBSTR函数截取最后一位
SELECT SUBSTR('###abcdefg***h', -1) FROM DUAL;
-- 方法2：使用LTRIM去掉左边不需要的字符集合
SELECT LTRIM('###abcdefg***h', '#abcdefg*') FROM DUAL;

--8 将字符串 'SDNDJDAAE' 截取成'AAE';
-- 方法1：使用SUBSTR从倒数第3位开始截取
SELECT SUBSTR('SDNDJDAAE', -3) FROM DUAL;
-- 方法2：使用SUBSTR正向截取
SELECT SUBSTR('SDNDJDAAE', 7, 3) FROM DUAL;

--9 将字符串 'SDNDJDAAE' 截取成'DND';
SELECT SUBSTR('SDNDJDAAE', 2, 3) FROM DUAL;

--10 使用函数找出2021年4月15号的下一个月的最后一天
-- 方法1：先加一个月，再求最后一天
SELECT LAST_DAY(ADD_MONTHS(TO_DATE('20210415', 'YYYYMMDD'), 1)) FROM DUAL;

--11 使用函数找出2021年4月15号的所在季度的第一天
SELECT TRUNC(TO_DATE('20210415', 'YYYYMMDD'), 'Q') FROM DUAL;

--12 使用函数找出2021年4月15号的所在是星期几
-- 方法1：使用TO_CHAR输出星期几（中文环境下为'星期四'，英文环境下为'THURSDAY'）
SELECT TO_CHAR(TO_DATE('20210415', 'YYYYMMDD'), 'DAY') FROM DUAL;
-- 方法2：输出数字（1-7），其中1代表星期日
SELECT TO_CHAR(TO_DATE('20210415', 'YYYYMMDD'), 'D') FROM DUAL;

--13 使用函数找出2021年4月15号三个月之前是哪一天
SELECT ADD_MONTHS(TO_DATE('20210415', 'YYYYMMDD'), -3) FROM DUAL;

--14 为员工表中的姓名做脱敏，保留两位字母，其余字母都变为*
--S***H 
-- 方法1：保留首尾字母，中间变为* (使用SUBSTR和RPAD组合)
SELECT RPAD(SUBSTR(ENAME, 1, 1), LENGTH(ENAME) - 1, '*') || SUBSTR(ENAME, -1) AS ENAME_NEW 
FROM EMP;

--SM***
-- 方法2：保留前两位字母，其余都变为* (使用SUBSTR和RPAD组合)
SELECT RPAD(SUBSTR(ENAME, 1, 2), LENGTH(ENAME), '*') AS ENAME_NEW 
FROM EMP;