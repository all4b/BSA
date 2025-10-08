--Из таблицы codesubmit необходимо вывести уникальные идентификаторы задач, для которых код был отправлен на проверку на языках SQL и Python.
select distinct 
	problem_id 
from codesubmit c  
where language_id in (
	select id
	from "language" l
	where c.language_id = 2 
		or c.language_id = 3
	) 
order by problem_id 

--Из таблицы users необходимо вывести идентификаторы пользователей, которые имеют более 5 правильных решений.
with users_is_right as (
	select c2.user_id
	from codesubmit c2 
	where c2.is_false = 0
	group by c2.user_id
	having count(c2.is_false) > 5
)
select  
	u.id 
from users u 
join users_is_right as u2
	on u.id = u2.user_id
order by u.id 

--Из таблицы problem необходимо вывести названия задач, у которых рейтинг не превышает 5 единиц от минимального рейтинга среди всех задач.
select  
	p."name" 
from problem p 
where p.rating <= 
	(
	select min(rating)
	from problem
	) + 5
order by p."name"  

--Из таблицы codesubmit необходимо вывести идентификаторы пользователей, которые до 20 мая 2022 года включительно не отправляли на проверку код более 30 дней.
select distinct user_id 
from codesubmit
where user_id not in 
(
	select distinct c.user_id
	from codesubmit c 
	where c.created_at > (make_date(2022,05,20) - interval '30 days')
)
order by user_id 

--Из таблицы users необходимо вывести идентификаторы пользователей с company_id = 1 и имеющих количество очков опыта на платформе больше, чем хотя бы у одного из пользователей с company_id = 10.
select u.id
from users u  
where company_id = 1
group by id
having sum(score) > 
	(
	select 
		sum(score) as sum_score
	from users
	where company_id = 10
	group by id
	order by sum_score
	limit 1	
	)
order by id 

--Из таблицы users необходимо вывести идентификаторы пользователей с company_id = 7 и имеющих количество очков опыта на платформе больше каждого из пользователей с company_id = 6.
select u.id
from users u  
where company_id = 7
	and score > 
		(
		select 
			score
		from users
		where company_id = 6
		order by score desc
		limit 1	
		)
order by id  





