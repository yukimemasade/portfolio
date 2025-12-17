--1)определить, влияет ли количество приобретаемых уроков в одной покупке на среднюю длительность занятия, 
--так как предполагаем, что, возможно, оптом (много уроков за один платеж) покупаются чаще короткие занятия, чем длительные.

SELECT AVG(sc.class_end_datetime - sc.class_start_datetime) as avg_len,
CASE WHEN user_id IN (SELECT sp.user_id
                             FROM skyeng_db.payments sp
                             WHERE status_name='success'
                             GROUP BY sp.user_id
                             HAVING AVG(sp.classes)>25 
                             AND COUNT(sp.transaction_datetime)>3
                            )                             
THEN 'segment' ELSE 'not segment' END nflag_sgm
FROM skyeng_db.classes sc
WHERE DATE_PART('year', sc.class_start_datetime)=2016
AND class_status='success'
AND (sc.class_end_datetime - sc.class_start_datetime) BETWEEN INTERVAL '20 minute'
         AND INTERVAL '3 hour'
GROUP BY user_id

--2)Нужно решить задачу через джоин таблицы classes и подзапроса.
  
SELECT AVG(sc.class_end_datetime-sc.class_start_datetime) as avg_len,
CASE WHEN t.user_id IS NOT NULL THEN 'segment' else 'not segment' END AS nflag_sgm
FROM skyeng_db.classes sc
FULL JOIN  (SELECT sp.user_id
       FROM skyeng_db.payments sp
       WHERE status_name='success'
       GROUP BY sp.user_id
       HAVING AVG(sp.classes)>25 
       AND count(sp.transaction_datetime)>3
      ) as t
ON sc.user_id=t.user_id
WHERE DATE_PART('year', sc.class_start_datetime)=2016
AND class_status='success'
AND (sc.class_end_datetime - sc.class_start_datetime) between interval '20 minute'
         and interval '3 hour'
GROUP BY t.user_id;

--Для вычисления количества каждой группы:

SELECT nflag_sgm, COUNT(nflag_sgm)
FROM (SELECT AVG(sc.class_end_datetime-sc.class_start_datetime) as avg_len,
CASE WHEN t.user_id IS NOT NULL THEN 'segment' else 'not segment' END AS nflag_sgm
FROM skyeng_db.classes sc
FULL JOIN  (SELECT sp.user_id
       FROM skyeng_db.payments sp
       WHERE status_name='success'
       GROUP BY sp.user_id
       HAVING AVG(sp.classes)>25 
       AND count(sp.transaction_datetime)>3
      ) as t
ON sc.user_id=t.user_id
WHERE DATE_PART('year', sc.class_start_datetime)=2016
AND class_status='success'
AND (sc.class_end_datetime - sc.class_start_datetime) between interval '20 minute'
         and interval '3 hour'
GROUP BY t.user_id) AS t1
GROUP BY nflag_sgm;


