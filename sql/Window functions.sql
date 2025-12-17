--1)Возьмите таблицу skybank.late_collection_clients и напишите скрипт, который сделает витрину со следующими полями

select id_client,
name_city,
case when gender='M' then 1 else 0 end as nflag_gender,
age,
first_time,
case when cellphone is not null then 1 else 0 end as nflag_cellphone,
is_active,
cl_segm,
amt_loan,
 to_date(date_loan, 'YYYY MM DD') as date_loan,
credit_type, 
sum(amt_loan) over (partition by cc.id_city) as sum_city,
amt_loan/sum(amt_loan) over (partition by cc.id_city)::float as ratio_sum_city,
sum(amt_loan) over (partition by cc.credit_type) as sum_credit,
amt_loan/sum(amt_loan) over (partition by cc.credit_type)::float as ratio_sum_credit,
sum(amt_loan) over (partition by cc.credit_type, cc.id_city) as sum_citycredit,
amt_loan/sum(amt_loan) over (partition by cc.credit_type, cc.id_city)::float as ratio_sum_citycredit,
count(amt_loan) over (partition by cc.id_city) as cnt_city,
count(amt_loan) over (partition by cc.credit_type) as cnt_cr,
count(amt_loan) over (partition by cc.credit_type, cc.id_city) as cnt_cr_city
from skybank.late_collection_clients cc
join skybank.region_dict rd 
on cc.id_city=rd.id_city

--2)Напишите запрос, в котором для каждого партнера найдите количество клиентов дошедших до каждой покупки (абсолютный ретеншен), 
а также вычислите доли дошедших до каждой покупки от дошедших до первой покупки (относительный базовый ретеншен).

SELECT  name_partner, 
SUM(CASE WHEN rn = 2 THEN 1 ELSE 0 END)::float/SUM(CASE WHEN rn= 1 THEN 1 ELSE 0 END) as ratio_2,
SUM(CASE WHEN rn = 3 THEN 1 ELSE 0 END)::float/SUM(CASE WHEN rn= 1 THEN 1 ELSE 0 END) as ratio_3,
SUM(CASE WHEN rn = 4 THEN 1 ELSE 0 END)::float/SUM(CASE WHEN rn= 1 THEN 1 ELSE 0 END) as ratio_4,
SUM(CASE WHEN rn = 5 THEN 1 ELSE 0 END)::float/SUM(CASE WHEN rn= 1 THEN 1 ELSE 0 END) as ratio_5,
SUM(CASE WHEN rn = 6 THEN 1 ELSE 0 END)::float/SUM(CASE WHEN rn= 1 THEN 1 ELSE 0 END) as ratio_6
    FROM 
      (
        SELECT 
             sc.user_id
           , sc.date_purchase
          , pd.name_partner
           , ROW_NUMBER() OVER (PARTITION BY sc.user_id ORDER BY sc.date_purchase ASC) AS rn
        FROM 
            skycinema.client_sign_up sc
        JOIN 
            skycinema.partner_dict pd 
        ON sc.partner = pd.id_partner
     ) t
GROUP BY 
     name_partner
--3)напишите SQL-запрос, который позволяет увидеть распределение количества покупок по полям is_trial, name_partner и rn (поле-ранг)
SELECT *, row_number() over (partition by is_trial, name_partner, rn 	
	order by date_purchase) as rang_of_clients
	FROM (SELECT cs.user_id,
    cs.purchase_id,
    cs.debit_kind,
    cs.is_trial,
    cs.date_purchase,
    cs.amt_payment,
    cs.partner,
    pd.name_partner,
    row_number() over (partition by user_id order by date_purchase) as rn
    FROM skycinema.client_sign_up cs
    JOIN skycinema.partner_dict pd
    ON cs.partner=pd.id_partner) as t;
