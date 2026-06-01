-- ###一、创建数据库和表，查找建表语句和插入语句的错误，注意不能修改表名和列名。并完成如下的建表操作。###
/*
 *学生表：student(学号,学生姓名,出生年月,性别)

  成绩表：score(学号,课程号,成绩)

  课程表：course(课程号,课程名称,教师号)

  教师表：teacher(教师号,教师姓名)
 */


-- 1、学生表
drop table student;
CREATE table student (
 sid number,--学号
 sname varchar2(20),--姓名
 sbirth varchar2(20), --出生日期
 sgender varchar2(20)--性别
);
INSERT into student values(1,'猴子','1989-01-01','男');
INSERT into student values(2,'猴子','1990-12-21','女');
INSERT into student values(3,'马云','1991-12-21','男');
INSERT into student values(4,'王思聪','1990-05-20','男');
INSERT into student values(5,'王思聪','1988-02-20','男');

SELECT * from student ;


-- 2.创建学生成绩表
drop table score ;
create table score (
  sid number ,--学号
  scoure number,--课程号
  sscore number --成绩
);

INSERT  into score values(1,1,86);
INSERT  into score values(1,2,90);
INSERT  into score values(1,3,99);
INSERT  into score values(2,2,60);
INSERT  into score values(2,3,80);
INSERT  into score values(3,1,89);
INSERT  into score values(3,2,85);
INSERT  into score values(3,3,80);

SELECT * from score ;


-- 3.创建课程表 
drop table course ;
create table course (
  scoure number(4) ,--课程号
  cname varchar2(20),--课程名称
  cteacher number  --教师号
);
INSERT  into course values(1,'语文',0002);
INSERT  into course values(2,'数学',0001);
INSERT  into course values(3,'英语',0003);

SELECT * from course ;

-- 4.创建教师表 
drop table teacher;
create table  teacher(
 cteacher NUMBER,--教师号
 tname varchar2 (20) --教师名字
);

INSERT into teacher values(0001,'孟扎扎');
INSERT into teacher values(0002,'马化腾');
INSERT into teacher values(0003,null);
INSERT into teacher values(0004,'');
commit ;
SELECT * from teacher ;


*********************************************************************
-- ###二、根据以上创建的表完成以下作业巩固基础语法，参加了考试的课程视为选修的课程###

-- 1、查询姓“猴”的学生名单
SELECT * 
FROM student
WHERE student.sname LIKE '猴%';


-- 2、查询姓名中最后一个字是聪的学生名单
SELECT * 
FROM student
WHERE student.sname LIKE '%聪';


-- 3、查询姓名中带猴的学生名单
SELECT * 
FROM student
WHERE student.sname LIKE '%猴%';


-- 4、查询姓“孟”老师的个数
SELECT COUNT(1) 
FROM teacher
WHERE teacher.tname LIKE '孟%';


-- 5、查询课程编号为“2”的平均成绩
SELECT AVG(score.sscore) 
FROM score
WHERE score.scoure = 2;


-- 6、查询各科成绩最高和最低分数
SELECT score.scoure,MAX(score.sscore), MIN(score.sscore)
FROM score
GROUP BY score.scoure;


-- 7、查询每门课程参加考试的学生数
SELECT score.scoure,COUNT(1)
FROM score
GROUP BY score.scoure;

 
-- 8、查询男生，女生人数
SELECT student.sgender, COUNT(student.sid) 
FROM student
GROUP BY student.sgender;
 
 
-- 9、查询平均成绩大于80分学生的学号和平均成绩
SELECT * 
FROM (SELECT score.sid, AVG(score.sscore) AS AVERAGE_SCORE
FROM score
GROUP BY score.sid)
WHERE AVERAGE_SCORE > 80;

 
-- 10、查询至少参加两门课程考试的学生学号、参加考试的课程数
SELECT * 
FROM (SELECT score.sid, COUNT(score.scoure) AS COURE_COUNT
FROM score
GROUP BY score.sid)
WHERE COURE_COUNT >= 2;

 
-- 11、查询同名同姓学生名单并统计人数
SELECT student.sname, COUNT(student.sid) 
FROM student
GROUP BY student.sname;

 
-- 12、查询分数高于70的课程成绩并按分数从大到小排序
SELECT *
FROM score
WHERE score.sscore > 70
ORDER BY score.sscore DESC;

 
-- 13、查询每门课程的平均成绩，结果按平均成绩升序排序，平均成绩相同时，按课程号降序排列
SELECT score.scoure, AVG(score.sscore) AS AVERAGE_SCORE
FROM score
GROUP BY score.scoure
ORDER BY AVERAGE_SCORE, score.scoure DESC;

 
-- 14、查询学生的总成绩并进行降序排列
SELECT score.sid, SUM(score.sscore) AS TOTAL_SCORE
FROM score
GROUP BY score.sid
ORDER BY TOTAL_SCORE DESC;


--15、查询参加考试的学生姓名、考试课程、分数
SELECT student.sname, score.scoure, score.sscore 
FROM student
LEFT JOIN score 
          ON student.sid = score.sid
--- 可优化

--16、查询分数都在85分（含）以上的学生姓名、平均成绩

--先查分数都在85分（含）以上的学生id
/*SELECT score.sid, AVG(score.sscore) AS AVERAGE_SCORE
FROM score 
HAVING MIN(score.sscore) >= 85
GROUP BY score.sid*/

--再查对应id的平均成绩
SELECT student.sid, student.sname, AVG(score.sscore) AS AVERAGE_SCORE
FROM student
LEFT JOIN score 
          ON student.sid = score.sid
GROUP BY student.sid, student.sname
HAVING MIN(score.sscore) >= 85
ORDER BY student.sid


--17、查询所有课程成绩均小于80分学生的学号、姓名
SELECT student.sid, student.sname
FROM student
LEFT JOIN score 
          ON student.sid = score.sid
GROUP BY student.sid, student.sname
HAVING MAX(score.sscore) < 80 --OR MAX(score.sscore) IS NULL
ORDER BY student.sid


--18、查询没有参加全部课程考试的学生的学号、姓名
SELECT student.sid, student.sname
FROM student
LEFT JOIN score 
          ON student.sid = score.sid
GROUP BY student.sid, student.sname
HAVING score.sscore IS NULL AND IS NOT NULL
ORDER BY student.sid

    
--19、查询出只选修了两门课程的全部学生的学号和姓名



--20、查询所有学生的学号、姓名、选课数、总成绩


 
--21、查询平均成绩大于85的所有学生的学号、姓名和平均成绩



--22、查询出每门课程的及格人数和不及格人数


 
--23、查询课程编号为3且课程成绩在80分以上的学生的学号和姓名


 
--24、检索编号1课程分数小于90，按照分数降序排列的学生信息


 
--25、查询不同老师所教授不同课程平均分从高到低显示



--26、查询课程名称为"数学"，且分数低于60的学生姓名和分数



--27、查询任何一门课程成绩在70分以上的学生信息


 
--28、查询两门及其以上不及格课程的同学的学号，姓名及其平均成绩

 
 
--29、查询所有课程成绩小于60分学生的学号、姓名



--30、查询没学过"孟扎扎"老师讲授的任一门课程的学生姓名
