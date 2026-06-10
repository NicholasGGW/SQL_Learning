/* Write your PL/SQL query statement below */

SELECT id
FROM (SELECT id,
        recordDate,
        Temperature,
        LAG(Temperature, 1) OVER(ORDER BY recordDate)  AS LAST_TEMPERATURE
FROM Weather) T1
WHERE T1.LAST_TEMPERATURE < T1.Temperature 



--#1280

SELECT T1.student_id, T1.student_name, T2.subject_name, NVL(T1.attended_exams, 0) AS attended_exams
FROM Subjects T2
LEFT JOIN (SELECT E.student_id, S.student_name, E.subject_name, COUNT(1) AS attended_exams
FROM Examinations E
LEFT JOIN Students S ON E.student_id = S.student_id
GROUP BY E.subject_name, E.student_id, S.student_name
ORDER BY E.student_id, E.subject_name
) T1 ON T2.subject_name = T1.subject_name
