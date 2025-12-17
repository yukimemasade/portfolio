--Рассчитайте среднее время ожидания в аэропорту, а также долю успешных выездов (flag_left_w_order) по всем заездам в аэропорты.
--Ограничьтесь только теми аэропортами, в которые было больше 100 заездов за всё время, и только теми водителями,
--которые отстояли в аэропортных очередях больше 12 часов за всё время.
--Нужна одна цифра без детализации по аэропортам.
with drvs as 
(
select id_driver
from SKYTAXI.airport_visit av
group by id_driver
having date_trunc('hour', sum(time_left-time_came))> interval '12 hours'
),
ports as 
(
select id_port
from SKYTAXI.airport_visit av
group by id_port
having count(distinct time_came)>100
)
SELECT avg(time_left-time_came) avg_leg, 
sum(flag_left_w_order)/count(flag_left_w_order) as ratio
FROM SKYTAXI.airport_visit av
join drvs d
on av.id_driver=d.id_driver
join ports p
on av.id_port=p.id_port
join (
       select id_driver, case when left_w_order>0 then 1.0 else 0.0 end as flag_left_w_order
        from SKYTAXI.airport_visit
      ) as t
on av.id_driver=t.id_driver
