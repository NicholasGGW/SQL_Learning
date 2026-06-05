-- 1. 用户信息表
DROP TABLE view_user_info;
CREATE TABLE view_user_info (
    user_id NUMBER PRIMARY KEY,
    user_name VARCHAR2(20),
    gender VARCHAR2(4),
    age NUMBER(3),
    city VARCHAR2(20)  -- 新增字段
);

-- 2. 影视分类表（支持递归：父分类）
DROP TABLE view_content_category;
CREATE TABLE view_content_category (
    content_name VARCHAR2(50) PRIMARY KEY,
    category VARCHAR2(20),
    parent_category VARCHAR2(20), -- 父分类（用于递归）
    release_year NUMBER(4),
    area VARCHAR2(10), -- 国产/欧美/日本
    tags VARCHAR2(50)  -- 标签
);

-- 3. 观影记录表
DROP TABLE view_record;
CREATE TABLE view_record (
    view_id NUMBER PRIMARY KEY,
    user_id NUMBER REFERENCES view_user_info(user_id),
    content_type VARCHAR2(10),
    content_name VARCHAR2(50) REFERENCES view_content_category(content_name),
    view_date DATE,
    score NUMBER(2),
    view_duration NUMBER,
    device VARCHAR2(20) -- 新增：手机/电脑/电视
);

-- ===================== 插入用户 =====================
INSERT INTO view_user_info VALUES(1, '张三', '男', 25, '北京');
INSERT INTO view_user_info VALUES(2, '李四', '女', 32, '上海');
INSERT INTO view_user_info VALUES(3, '王五', '男', 19, '广州');
INSERT INTO view_user_info VALUES(4, '赵六', '女', 28, '深圳');
INSERT INTO view_user_info VALUES(5, '孙七', '男', 45, '杭州');
INSERT INTO view_user_info VALUES(6, '周八', '女', 22, '成都');
INSERT INTO view_user_info VALUES(7, '吴九', '男', 30, '重庆');
INSERT INTO view_user_info VALUES(8, '郑十', '女', 27, '武汉');
INSERT INTO view_user_info VALUES(9, '钱十一', '未知', 23, '南京');
INSERT INTO view_user_info VALUES(10, '冯十二', '男', 35, '西安');
INSERT INTO view_user_info VALUES(11, '陈十三', '女', 26, '青岛');
INSERT INTO view_user_info VALUES(12, '刘十四', '男', 38, '天津');

-- ===================== 插入影视（带递归父分类） =====================
INSERT INTO view_content_category VALUES('《隐秘的角落》','悬疑','剧情类',2020,'国产','推理');
INSERT INTO view_content_category VALUES('《你好，李焕英》','喜剧','剧情类',2021,'国产','温情');
INSERT INTO view_content_category VALUES('《流浪地球》','科幻','特效类',2019,'国产','灾难');
INSERT INTO view_content_category VALUES('《甄嬛传》','宫斗','剧情类',2011,'国产','古装');
INSERT INTO view_content_category VALUES('《龙猫》','动画','动漫类',1988,'日本','治愈');
INSERT INTO view_content_category VALUES('《开端》','悬疑','剧情类',2022,'国产','时间循环');
INSERT INTO view_content_category VALUES('《夏洛特烦恼》','喜剧','剧情类',2015,'国产','搞笑');
INSERT INTO view_content_category VALUES('《三体》','科幻','特效类',2023,'国产','宇宙');
INSERT INTO view_content_category VALUES('《知否知否》','剧情','剧情类',2018,'国产','宅斗');
INSERT INTO view_content_category VALUES('《哪吒之魔童降世》','动画','动漫类',2019,'国产','神话');
INSERT INTO view_content_category VALUES('《沉默的真相》','悬疑','剧情类',2020,'国产','社会派');
INSERT INTO view_content_category VALUES('《飞驰人生》','喜剧','剧情类',2019,'国产','赛车');
INSERT INTO view_content_category VALUES('《星际穿越》','科幻','特效类',2014,'欧美','时空');
INSERT INTO view_content_category VALUES('《琅琊榜》','剧情','剧情类',2015,'国产','权谋');
INSERT INTO view_content_category VALUES('《千与千寻》','动画','动漫类',2001,'日本','成长');
INSERT INTO view_content_category VALUES('《盗梦空间》','科幻','特效类',2010,'欧美','悬疑');
INSERT INTO view_content_category VALUES('《疯狂动物城》','动画','动漫类',2016,'欧美','喜剧');
INSERT INTO view_content_category VALUES('《让子弹飞》','喜剧','剧情类',2010,'国产','讽刺');

-- ===================== 插入观影记录 =====================
INSERT INTO view_record VALUES(101,1,'剧集','《隐秘的角落》',TO_DATE('2024-01-05','YYYY-MM-DD'),9,500,'手机');
INSERT INTO view_record VALUES(102,1,'电影','《你好，李焕英》',TO_DATE('2024-02-10','YYYY-MM-DD'),8,128,'电视');
INSERT INTO view_record VALUES(103,1,'电影','《流浪地球》',TO_DATE('2024-03-15','YYYY-MM-DD'),10,125,'电脑');
INSERT INTO view_record VALUES(104,2,'剧集','《甄嬛传》',TO_DATE('2024-01-20','YYYY-MM-DD'),7,800,'电视');
INSERT INTO view_record VALUES(105,2,'电影','《龙猫》',TO_DATE('2024-02-25','YYYY-MM-DD'),9,86,'手机');
INSERT INTO view_record VALUES(106,3,'剧集','《开端》',TO_DATE('2024-03-01','YYYY-MM-DD'),8,360,'电脑');
INSERT INTO view_record VALUES(107,3,'电影','《夏洛特烦恼》',TO_DATE('2024-03-08','YYYY-MM-DD'),7,90,'手机');
INSERT INTO view_record VALUES(108,3,'剧集','《三体》',TO_DATE('2024-04-12','YYYY-MM-DD'),9,480,'电视');
INSERT INTO view_record VALUES(109,4,'剧集','《知否知否》',TO_DATE('2024-01-18','YYYY-MM-DD'),8,720,'电视');
INSERT INTO view_record VALUES(110,4,'电影','《哪吒之魔童降世》',TO_DATE('2024-02-12','YYYY-MM-DD'),10,110,'电脑');
INSERT INTO view_record VALUES(111,5,'剧集','《沉默的真相》',TO_DATE('2024-03-20','YYYY-MM-DD'),9,600,'手机');
INSERT INTO view_record VALUES(112,5,'电影','《飞驰人生》',TO_DATE('2024-04-05','YYYY-MM-DD'),7,98,'电视');
INSERT INTO view_record VALUES(113,5,'电影','《星际穿越》',TO_DATE('2024-04-18','YYYY-MM-DD'),10,169,'电脑');
INSERT INTO view_record VALUES(114,6,'剧集','《琅琊榜》',TO_DATE('2024-02-15','YYYY-MM-DD'),9,540,'手机');
INSERT INTO view_record VALUES(115,6,'电影','《千与千寻》',TO_DATE('2024-03-10','YYYY-MM-DD'),8,125,'电视');
INSERT INTO view_record VALUES(116,7,'电影','《你好，李焕英》',TO_DATE('2024-01-08','YYYY-MM-DD'),8,128,'电脑');
INSERT INTO view_record VALUES(117,7,'剧集','《开端》',TO_DATE('2024-02-22','YYYY-MM-DD'),7,360,'手机');
INSERT INTO view_record VALUES(118,7,'电影','《流浪地球》',TO_DATE('2024-03-25','YYYY-MM-DD'),9,125,'电视');
INSERT INTO view_record VALUES(119,8,'电影','《哪吒之魔童降世》',TO_DATE('2024-04-02','YYYY-MM-DD'),9,110,'电脑');
INSERT INTO view_record VALUES(120,8,'电影','《夏洛特烦恼》',TO_DATE('2024-04-10','YYYY-MM-DD'),6,90,'手机');
INSERT INTO view_record VALUES(121,9,'剧集','《隐秘的角落》',TO_DATE('2024-01-30','YYYY-MM-DD'),8,500,'电视');
INSERT INTO view_record VALUES(122,9,'剧集','《三体》',TO_DATE('2024-02-18','YYYY-MM-DD'),8,480,'电脑');
INSERT INTO view_record VALUES(123,10,'电影','《星际穿越》',TO_DATE('2024-03-05','YYYY-MM-DD'),10,169,'手机');
INSERT INTO view_record VALUES(124,10,'剧集','《沉默的真相》',TO_DATE('2024-03-12','YYYY-MM-DD'),9,600,'电视');
INSERT INTO view_record VALUES(125,2,'电影','《流浪地球》',TO_DATE('2024-04-20','YYYY-MM-DD'),8,125,'电脑');
INSERT INTO view_record VALUES(126,4,'剧集','《开端》',TO_DATE('2024-01-12','YYYY-MM-DD'),9,360,'手机');
INSERT INTO view_record VALUES(127,6,'电影','《飞驰人生》',TO_DATE('2024-02-08','YYYY-MM-DD'),7,98,'电视');
INSERT INTO view_record VALUES(128,8,'剧集','《琅琊榜》',TO_DATE('2024-03-18','YYYY-MM-DD'),8,540,'电脑');
INSERT INTO view_record VALUES(129,9,'电影','《龙猫》',TO_DATE('2024-04-08','YYYY-MM-DD'),9,86,'手机');
INSERT INTO view_record VALUES(130,1,'剧集','《琅琊榜》',TO_DATE('2024-04-25','YYYY-MM-DD'),8,540,'电视');
INSERT INTO view_record VALUES(131,11,'电影','《盗梦空间》',TO_DATE('2024-02-05','YYYY-MM-DD'),9,148,'电脑');
INSERT INTO view_record VALUES(132,11,'电影','《疯狂动物城》',TO_DATE('2024-03-19','YYYY-MM-DD'),10,108,'手机');
INSERT INTO view_record VALUES(133,12,'电影','《让子弹飞》',TO_DATE('2024-01-15','YYYY-MM-DD'),10,130,'电视');
INSERT INTO view_record VALUES(134,12,'剧集','《知否知否》',TO_DATE('2024-03-22','YYYY-MM-DD'),8,720,'电脑');

COMMIT;

--练习题

-- 1. 查询所有电影类型的观影记录，并根据评分展示评价等级：
--    评分≥9为优秀，7~8为良好，≤6为一般；显示影视名称、观看时间、评分、评价等级
-- 2. 查询所有用户信息，并标注年龄段：<20青少年，20~30青年，>30中青年
-- 3. 统计不同性别用户的平均观影评分，结果保留1位小数
-- 4. 按2024年各季度统计每季度观影总次数和总观看时长
-- 5. 找出观看过动画类影视且年龄小于30岁的用户姓名与性别
-- 6. 查询上映年份早于2015年且有观影记录的影视名称及分类
-- 7. 统计观看时长超过120分钟的记录中，剧集与电影各自的数量
-- 8. 查询用户名长度大于2个字符且性别不为“未知”的用户信息
-- 9. 统计每位用户的观影总次数、总观看时长、平均评分
-- 10. 统计每个影视分类的平均评分、累计观看人次
-- 11. 找出观影次数不少于3次的用户姓名及其观影次数
-- 12. 找出2024年2月内评分最高的3部影视名称及评分
-- 13. 查询每位用户的最高评分及对应的影视名称
-- 14. 统计科幻类每部影片的观看人数，并找出观看人数最多的影片
-- 15. 统计20~30岁用户对各影视分类的平均评分
-- 16. 找出张三和李四共同观看过的影视名称
-- 17. 查询所有影视分类及其上级父分类，展示层级关系
-- 18. 查询属于“剧情类”顶级分类下的影视名称及细分类型
-- 19. 展示每个分类的层级路径与所在深度
-- 20. 对每个用户的观影记录按评分从高到低进行排名
-- 21. 将所有分类按平均评分排名，显示排名、分类、平均分
-- 22. 为每条观影记录附加显示所属分类下的最高评分
-- 23. 按观看时间顺序为每个用户计算累计观看时长
-- 24. 找出每个分类中评分前两名的影视及评分
-- 25. 计算每条观影记录前后各一条同分类记录的平均评分
-- 26. 查询每个用户平均评分，并与全体用户整体平均分对比
-- 27. 按观看时间顺序显示每个用户上一次观影的评分
-- 28. 按年龄段分区，统计各年龄段内各分类的平均评分
-- 29. 统计每个用户评分高于所属分类平均分的次数
-- 30. 找出观看人数不少于3人且平均评分不低于8分的影视
