/*
Из таблицы users требуется вывести следующую информацию о пользователях:
	Идентификатор
	Логин
	Почта
Домен электронной почты (вычисляется как часть электронной почты после символа @)
*/
select 
	id, 
	username, 
	email, 
	right(email, length(email) - position('@' in email)) as "domain"
from users
order by id

-- Из таблицы users требуется вывести информацию о пользователях, которые имеют домен электронной почты bk.ru.
select 
	id, 
	username, 
	email
from users
where email ilike '%bk.ru'
order by id

/*
Из таблицы users требуется вывести следующую информацию о пользователях:
	Идентификатор
	Логин
Текстовое описание идентификатора формата "Идентификатор пользователя равен x", где x - значение id
*/
select 
	id,
	username,
	'Идентификатор пользователя равен ' || id as text_user_id
from users
order by id

/*
Из таблицы users требуется вывести следующую информацию о пользователях:
	Идентификатор
	Логин
	Имя
	Фамилия
Приветственное имя пользователя: 
	если есть имя, то вывести имя пользователя, 
	если имени нет, но есть фамилия, то вывести фамилию, 
	если отсутствуют как имя, так и фамилия, то вывести Дорогой друг
*/
select 
	id,
	username,
	first_name,
	last_name,
	case 
		when first_name is not null then first_name
		when last_name is not null then last_name
		else 'Дорогой друг'
	end as display_name
from users
order by id

/*
Из таблицы users требуется вывести следующую информацию о пользователях:
	Идентификатор
	Логин
	Количество очков опыта на платформе
	Группа пользователя по количеству очков опыта на платформе
Правила присвоения группы пользователю по количеству очков опыта на платформе:
	Если значение строго больше 300, то Мастер
	Если значение строго больше 150, то Эксперт
	Если значение строго больше 75, то Продвинутый
	В остальных случаях Новичок
*/
select 
	id,
	username,
	score,
	case 
		when score > 300 then 'Мастер'
		when score > 150 then 'Эксперт'
		when score > 75 then 'Продвинутый'
		else 'Новичок'
	end as group_user
from users
order by id

/*
Из таблицы users требуется вывести информацию о пользователях, которые зарегистрировались на платформе в течение 45 дней после 2022-01-01.
*/
select 
	id,
	username,
	date_joined
from users
where 
	extract(days from date_joined - make_date(2022, 1, 1)) >= 0
	and
	extract(days from date_joined - make_date(2022, 1, 1)) < 45
order by 
	date_joined desc,
	id
	
--Из таблицы users требуется вывести информацию о пользователях, которые зарегистрировались на платформе в 2021 году.
select 
	id,
	username,
	date_joined
from users
where to_char(date_joined, 'YYYY') = '2021' 
--where extract(years from date_joined) = '2021'
order by id






