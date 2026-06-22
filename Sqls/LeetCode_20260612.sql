--1341
With T1 AS
(SELECT M.user_id, U.name, COUNT(M.movie_id) AS comment_cnt
FROM MovieRating M
INNER JOIN Users U ON U.user_id = M.user_id
GROUP BY M.user_id, U.name
ORDER BY U.name),
T2 AS
(SELECT MR.movie_id, M.title, AVG(MR.rating) AS average_rating
FROM MovieRating MR
INNER JOIN Movies M ON MR.movie_id = M.movie_id
WHERE TO_CHAR(MR.created_at,'YYYYMM') = '202002' 
GROUP BY MR.movie_id, M.title)
SELECT MIN(T1.name) AS results
FROM T1
WHERE T1.comment_cnt = (SELECT MAX(T1.comment_cnt) FROM T1)
UNION ALL
SELECT MIN(T2.title) AS results
FROM T2
WHERE T2.average_rating = (SELECT MAX(T2.average_rating) FROM T2)

--1484
--需要将分组好的信息不按照聚合函数降维成一个值，需要用LISTAGG函数，返回一个有分隔符的字符串

LISTAGG(product,',') WITHIN GROUP (ORDER BY product) AS products


--ORA-00918: column ambiguously defined
--代表有没有清晰指定的列字段