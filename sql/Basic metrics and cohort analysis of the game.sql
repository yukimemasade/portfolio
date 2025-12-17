--1)В марте 2023 года маркетинг провёл акцию: чем чаще игрок заходил в игру, тем больше получал бесплатных кристаллов. Акция шла первые 3 недели марта.
--Вопрос: Видим ли мы позитивный эффект этой акции в метриках?
--In March 2023, the marketing team ran a promotion: the more often a player logged into the game, the more free crystals they received. The promotion ran for the first three weeks of March.
--Question: Are we seeing a positive impact from this promotion in the metrics?

 --DAU
SELECT distinct count(*), DATE_TRUNC('DAY', start_session) AS DAU
FROM skygame.game_sessions
WHERE start_session::date between '2023-03-01' AND '2023-03-21'
GROUP BY DAU
ORDER BY DAU;
--MAU
SELECT distinct count(*), DATE_TRUNC('MONTH', start_session) AS MAU
FROM skygame.game_sessions
WHERE start_session::date between '2023-03-01' AND '2023-03-21'
GROUP BY MAU
ORDER BY MAU;
--WAU
SELECT distinct count(*), DATE_TRUNC('WEEK', start_session) AS WAU
FROM skygame.game_sessions
WHERE start_session::date between '2023-03-01' AND '2023-03-21'
GROUP BY WAU
ORDER BY WAU;

--2)Новое условие: бонусы получат игроки, которые проводят в игре больше всего времени. Но в первую очередь нас интересуют игроки, зарегистрированные в 2022 году.
--Выведите топ-25 игроков по этому показателю
 SELECT (gs.end_session-gs.start_session) as duration
FROM skygame.game_sessions gs
JOIN skygame.users us
ON gs.id_user=us.id_user
WHERE DATE_PART('year', us.reg_date)=2022
AND gs.end_session IS NOT NULL
ORDER BY duration DESC
LIMIT 25;

--3)Найдите количество таких «битых» строк и их долю от общего числа строк.
--Посчитайте долю проблемных записей для каждого device_type (ios и android).
--Определите, какой процент всех проблемных записей приходится на ios, а какой — на android. 

SELECT sum(CASE WHEN gs.end_session is null then 1.0 else 0.0 end) as cnt_nl,
sum(CASE WHEN gs.end_session is null then 1.0 else 0.0 end)/count(*) as fraction,
sum(CASE WHEN us.dev_type like 'ios' and gs.end_session is null then 1.0 else 0.0 end)/count(*) as ios,
sum(CASE WHEN us.dev_type like 'android' and gs.end_session is null then 1.0 else 0.0 end)/count(*) as android,
sum(CASE WHEN us.dev_type like 'ios' and gs.end_session is null then 1.0 else 0.0 end)/count(CASE WHEN us.dev_type like 'ios' then 1.0 else 0.0 end)*100 as fraction_ios,
sum(CASE WHEN us.dev_type like 'android' and gs.end_session is null then 1.0 else 0.0 end)/count(CASE WHEN us.dev_type like 'android' then 1.0 else 0.0 end)*100 as fraction_android
FROM skygame.game_sessions gs
JOIN skygame.users us
ON gs.id_user=us.id_user;
