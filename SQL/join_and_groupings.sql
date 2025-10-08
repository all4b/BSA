/*
Из таблиц users и coderun необходимо вывести следующую информацию о пользователях, которые отправляли на выполнение код в период с 1 по 30 апреля 2021 года:
	Идентификатор пользователя
	Логин пользователя
	Дата и время регистрации пользователя
	Идентификатор задачи
*/
select
	u.id,
	u.username,
	u.date_joined,
	c.problem_id 
from coderun c 
join users u 
on c.user_id = u.id
where c.created_at between make_date(2021, 04, 01) and make_date(2021, 04, 30) 
order by id, problem_id 

/*
Из таблиц language, languagetoproblem и problem требуется вывести следующую информацию:
	Название языка программирования
	Название задачи
	Сложность задачи
*/
select
	l."name" as language_name,
	p."name" as problem_name,
	p.complexity 
from "language" l  
join languagetoproblem lp  
on l.id = lp.lang_id
join problem p 
on p.id = lp.pr_id 
order by problem_name 

/*
Из таблиц users, coderun и codesubmit требуется вывести уникальные логины пользователей, которые отправляли на выполнение код, но не отправляли его на проверку.
Выведите только тех пользователей, которые зарегистрировались в апреле 2021.
*/
select distinct(u.username) 
from users u
join coderun c 
	on u.id = c.user_id
left join codesubmit cs
	on u.id = cs.user_id 
where 
	u.date_joined between '2021-04-01' and '2021-04-30'
	and 
	cs.user_id isnull
order by u.username 

/*
Напишите запрос, который из таблиц coderun и codesubmit объединяет информацию о всех операциях с кодом - запуск на выполнение и отправка на проверку. В результате должны быть следующие столбцы:
	Идентификатор пользователя
	Идентификатор задачи
	Дата и время отправки кода
	Тип попытки (run или submit)
	Идентификатор языка программирования
*/
select
	c.user_id, 
	c.problem_id,
	c.created_at,
	'run' as attempt_type,
	c.language_id 
from coderun c 
union all
select
	cs.user_id,
	cs.problem_id,
	cs.created_at,
	'submit' as attempt_type,
	cs.language_id
from codesubmit cs 
order by user_id 

/*
Из таблиц users, transaction и transactiontype требуется вывести информацию только о тех пользователях, которые совершали транзакции типа Пополнение кошелька
	Логин
	Общая сумма транзакций 
*/
select
	u.username,
	sum(t.value) as total_score
from users u 
join "transaction" t  
	on u.id = t.user_id 
join transactiontype tp  
	on t.type_id = tp."type"
where tp.description = 'Пополнение кошелька'
group by u.username
having sum(t.value) > 500
order by u.username  

/*
Из таблиц company и users требуется вывести количество активных и неактивных пользователей по всем наименованиям компаний.
*/
select  
	c."name" as company_name,
	coalesce(count(case when is_active = 1 then 1 end), 0) as cnt_active_users,
	coalesce(count (case when is_active = 0 then 1 end), 0) as cnt_not_active_users
from users u
right join company c 
	on u.company_id = c.id
group by c."name" 
order by company_name 

--Из таблицы company и users требуется вывести фамилии пользователей в виде списка по всем наименованиям компаний, разделяя фамилии запятой и пробелом (‘, ’) в отсортированном по возрастанию поля email.
select  
	c."name" as company_name,
	string_agg(u.last_name, ', ' order by u.email) as list_last_name
from users u
join company c 
	on u.company_id = c.id
where u.last_name is not null
group by c."name"
order by company_name

/*
Из таблиц users, codesubmit и problem требуется вывести следующую информацию по всем пользователям:
	Идентификатор
	Логин
	Наименование задачи, которую пользователь наиболее часто отправлял на проверку
*/
select  
	u.id,
	u.username,
	coalesce(mode() within group(order by p."name"), 'Пользователь ничего не отправлял') as mode_problems
from users u
left join codesubmit c 
	on c.user_id = u.id
left join problem p 
	on c.problem_id = p.id 
group by u.id
order by u.id






