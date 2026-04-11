begin;

with upsert_user as (
    insert into users (telegram_id, name, timezone, currency)
    values (448027140, 'Надежда', 'Europe/Samara', 'RUB')
    on conflict (telegram_id) do update
    set
        name = excluded.name,
        timezone = excluded.timezone,
        currency = excluded.currency
    returning id
)
insert into categories (user_id, kind, name, sort_order)
select
    u.id,
    v.kind,
    v.name,
    v.sort_order
from upsert_user u
cross join (
    values
        ('expense', 'Жилье', 10),
        ('expense', 'Продукты', 20),
        ('expense', 'Еда вне дома', 30),
        ('expense', 'Культура и досуг', 40),
        ('expense', 'Путешествия', 50),
        ('expense', 'Собака', 60),
        ('expense', 'Машина', 70),
        ('expense', 'Одежда и обувь', 80),
        ('expense', 'Подарки и близкие', 90),
        ('expense', 'Прочее', 100),
        ('investment', 'Облигации', 10)
) as v(kind, name, sort_order)
on conflict (user_id, kind, name) do update
set
    sort_order = excluded.sort_order,
    is_archived = false;

with target_user as (
    select id
    from users
    where telegram_id = 448027140
),
subcategory_seed as (
    select *
    from (
        values
            ('expense', 'Жилье', 'Аренда', 10),
            ('expense', 'Еда вне дома', 'Доставка', 10),
            ('expense', 'Еда вне дома', 'Кафе/рестораны', 20),
            ('expense', 'Еда вне дома', 'Кофе', 30),
            ('expense', 'Культура и досуг', 'Театры', 10),
            ('expense', 'Культура и досуг', 'Концерты', 20),
            ('expense', 'Культура и досуг', 'Выставки', 30),
            ('expense', 'Культура и досуг', 'Музеи', 40),
            ('expense', 'Культура и досуг', 'Развлечения', 50),
            ('expense', 'Путешествия', 'Билеты', 10),
            ('expense', 'Путешествия', 'Жилье', 20),
            ('expense', 'Собака', 'Корм', 10),
            ('expense', 'Собака', 'Вкусняшки', 20),
            ('expense', 'Собака', 'Тренировки', 30),
            ('expense', 'Машина', 'Ремонт', 10),
            ('expense', 'Машина', 'Бензин', 20),
            ('expense', 'Машина', 'Штрафы', 30),
            ('expense', 'Машина', 'Обслуживание', 40),
            ('expense', 'Подарки и близкие', 'Цветы', 10),
            ('expense', 'Подарки и близкие', 'Подарки', 20),
            ('expense', 'Подарки и близкие', 'К чаю', 30)
    ) as t(kind, category_name, subcategory_name, sort_order)
)
insert into subcategories (category_id, name, sort_order)
select
    c.id,
    s.subcategory_name,
    s.sort_order
from subcategory_seed s
join target_user u on true
join categories c
    on c.user_id = u.id
   and c.kind = s.kind
   and c.name = s.category_name
on conflict (category_id, name) do update
set
    sort_order = excluded.sort_order,
    is_archived = false;

with target_user as (
    select id
    from users
    where telegram_id = 448027140
)
insert into goals (user_id, kind, name, target_amount_minor, sort_order)
select
    u.id,
    v.kind,
    v.name,
    v.target_amount_minor,
    v.sort_order
from target_user u
cross join (
    values
        ('reserve', 'Неприкосновенный запас', null::bigint, 10),
        ('deposit', 'Вклад', null::bigint, 20)
) as v(kind, name, target_amount_minor, sort_order)
on conflict (user_id, name) do update
set
    target_amount_minor = excluded.target_amount_minor,
    sort_order = excluded.sort_order,
    is_archived = false;

with target_user as (
    select id
    from users
    where telegram_id = 448027140
),
rule_seed as (
    select *
    from (
        values
            ('кофе', 'expense', 'Еда вне дома', 'Кофе', 10),
            ('доставка', 'expense', 'Еда вне дома', 'Доставка', 20),
            ('кафе', 'expense', 'Еда вне дома', 'Кафе/рестораны', 30),
            ('ресторан', 'expense', 'Еда вне дома', 'Кафе/рестораны', 40),
            ('продукты', 'expense', 'Продукты', null, 50),
            ('аренда', 'expense', 'Жилье', 'Аренда', 60),
            ('театр', 'expense', 'Культура и досуг', 'Театры', 70),
            ('концерт', 'expense', 'Культура и досуг', 'Концерты', 80),
            ('выставка', 'expense', 'Культура и досуг', 'Выставки', 90),
            ('музей', 'expense', 'Культура и досуг', 'Музеи', 100),
            ('развлечения', 'expense', 'Культура и досуг', 'Развлечения', 110),
            ('билеты', 'expense', 'Путешествия', 'Билеты', 120),
            ('отель', 'expense', 'Путешествия', 'Жилье', 130),
            ('корм', 'expense', 'Собака', 'Корм', 140),
            ('вкусняшки', 'expense', 'Собака', 'Вкусняшки', 150),
            ('тренировка собаки', 'expense', 'Собака', 'Тренировки', 160),
            ('бензин', 'expense', 'Машина', 'Бензин', 170),
            ('ремонт машины', 'expense', 'Машина', 'Ремонт', 180),
            ('штраф', 'expense', 'Машина', 'Штрафы', 190),
            ('обслуживание машины', 'expense', 'Машина', 'Обслуживание', 200),
            ('цветы', 'expense', 'Подарки и близкие', 'Цветы', 210),
            ('подарок', 'expense', 'Подарки и близкие', 'Подарки', 220),
            ('к чаю', 'expense', 'Подарки и близкие', 'К чаю', 230),
            ('облигации', 'investment', 'Облигации', null, 240)
    ) as t(phrase, kind, category_name, subcategory_name, priority)
)
insert into keyword_rules (user_id, phrase, category_id, subcategory_id, priority, is_active)
select
    u.id,
    r.phrase,
    c.id,
    s.id,
    r.priority,
    true
from rule_seed r
join target_user u on true
join categories c
    on c.user_id = u.id
   and c.kind = r.kind
   and c.name = r.category_name
left join subcategories s
    on s.category_id = c.id
   and s.name = r.subcategory_name
on conflict (user_id, phrase) do update
set
    category_id = excluded.category_id,
    subcategory_id = excluded.subcategory_id,
    priority = excluded.priority,
    is_active = true;

commit;
