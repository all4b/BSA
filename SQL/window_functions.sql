/*
Из таблицы problem необходимо вывести следующую информацию о задачах:
	Наименование задачи
	Рейтинг задачи
	Ранг задачи, где 1 ранг имеют задачи с наибольшим рейтингом
*/
select 
	"name",
	rating,
	rank() over(order by rating desc) as rank_rating
from problem
where rating is not null
order by rank_rating, "name"  

/*
Из таблицы users необходимо вывести следующую информацию о пользователях:
	Идентификатор
	Логин
	Ранг пользователя, где 1 ранг имеют пользователи с наибольшим количеством очков опыта на платформе
*/
select 
	id,
	username,
	dense_rank() over(order by score desc) as dns_rank_score
from users
where score > 100
order by dns_rank_score, id  

/*
Из таблицы problem с помощью функции NTILE необходимо распределить задачи на 5 групп по их рейтингу и вывести следующую информацию:
	Группа, к которой относится задача (первой группе соответствуют задачи с наибольшим рейтингом)
	Наименование задачи
	Рейтинг задачи
*/
select 
	ntile(5) over(order by rating desc) as group_problem,
	"name",
	rating
from problem
where rating is not null
order by group_problem, rating desc, "name"  

/*
Напишите запрос, который выведет последнего зарегистрированного пользователя для компании. 
*/
with r as (
	select 
		c."name" as company_name,
		company_id,
		username,
		date_joined,
		row_number() over (partition by company_id order by date_joined desc) as r
	from users u 
	join company c 
		on u.company_id = c.id 
	where company_id is not null
)
select 
	company_name,
	username
from r 
where r = 1
order by r.company_name, date_joined desc

/*
Напишите запрос, который выведет количество отправок кода на проверку для месяца, имеющего 7-й ранг по количеству отправок кода на проверку, отсортированных по убыванию. 
*/
with t as (
	select date_trunc('month', created_at) as ym
	from codesubmit c	
),
r as (
select 
	ym,
	count(*) as submission_count,
	rank() over (order by count(*) desc) as rk
from t
group by ym
order by rk
)
select submission_count
from r
where rk = 7

/*
Напишите запрос, который выведет для языков программирования название первой и последней задачи, отправленных проверку. 
*/
with common as (
select 
	c.created_at,
	p."name" as submission_name,
	l."name" as language_name,
	first_value(p."name") over (partition by l."name" order by c.created_at) as first_submission,
	last_value(p."name") over (partition by l."name" order by c.created_at rows between unbounded preceding and unbounded following) as last_submission
from codesubmit c 
join "language" l 
	on c.language_id = l.id
join problem p 
	on c.problem_id = p.id
order by l."name"
)
select distinct  
	language_name,
  	first_submission,
  	last_submission	
from common
order by language_name

/*
Напишите запрос, который выведет следующую информацию:
	Год и месяц регистрации пользователя в формате YYYY-MM
	Общее количество очков опыта на платформе для каждого месяца
	Общее количество очков опыта на платформе за предыдущий месяц
	Разница в баллах между текущим общим количеством очков опыта на платформе за месяц и общим количеством очков опыта на платформе за месяц и предыдущей суммой баллов
*/
with cnt_users_month as
(
select
	to_char(date_joined, 'YYYY-MM') as year_month,
	sum(score) as sum_score
from users
group by year_month 
)
select
	*,
	lag(sum_score) over(order by year_month) as previous_sum_score,
	sum_score - lag(sum_score) over(order by year_month) as score_difference
from cnt_users_month 
order by year_month 

/*
Напишите запрос, который из таблицы codesubmit выводит следующую информацию:
	Отформатированная в виде текста дата и время проверки кода в формате YYYY-MM
	Количество отправленных на проверку уникальных задач за каждый месяц
	Скользящее среднее отправленных на проверку уникальных задач за последние три месяца.
*/
with cnt_problems as 
(
select 
	to_char(created_at, 'YYYY-MM') as yyyy_mm,
	count(distinct problem_id) as cnt_unique_problems
from codesubmit
group by yyyy_mm
order by yyyy_mm
)
select 
	*,
	avg(cnt_unique_problems) over (order by yyyy_mm rows between 2 preceding and current row)
from cnt_problems  

/*
Давайте возьмем период с 2022-01-01 и последующие 150 дней и рассчитаем следующие показатели:
	date_from_calendar: дата, округленная до дня (без времени)
	daily_active_users_cnt: количество уникальных активных пользователей за день (DAU)
	max_dau_cnt: максимальный DAU за все время
	diff_dau: разница между текущим DAU и максимальным значением DAU за все время
Примечания
	Заходы пользователя на платформу находятся в таблице userentry. 
	Обязательно нужно учесть дни без захода на платформу (будет полезна функция generate_series) 
	Если в определенный день заходов на платформу не было, то есть нет и DAU, то выведите 0.
	Для расчета DAU оставьте только 2022 год. 
*/
with table_days as 
	(
	select generate_series('2022-01-01'::timestamp, '2022-01-01'::timestamp + interval '150 days', '1 days') as date_from_calendar
	),
userentry_days as 
	(
	select 
		date_trunc('day', entry_at) as days
		, *
	from userentry u 
	where u.entry_at between '2022-01-01' and '2022-12-31'
	order by days
	),
cnt_users_days as 
	(
	select 
		td.date_from_calendar,
		count(distinct ud.id) as daily_active_users_cnt,
		max(count(distinct ud.id)) over (rows between unbounded preceding and current row) as max_dau_cnt
	from table_days td 
	left join userentry_days ud
		on ud.days = td.date_from_calendar
	group by td.date_from_calendar
	order by td.date_from_calendar
	)
select 
	*,
	daily_active_users_cnt - max_dau_cnt as diff_dau
from cnt_users_days
order by date_from_calendar
	




