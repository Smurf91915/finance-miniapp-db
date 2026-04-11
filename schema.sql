create extension if not exists pgcrypto;

create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    telegram_id bigint not null unique,
    name text,
    timezone text not null default 'Europe/Samara',
    currency char(3) not null default 'RUB',
    created_at timestamptz not null default now()
);

create table if not exists categories (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    kind text not null check (kind in ('expense', 'investment')),
    name text not null,
    is_archived boolean not null default false,
    sort_order integer not null default 0,
    created_at timestamptz not null default now(),
    unique (user_id, kind, name)
);

create table if not exists subcategories (
    id uuid primary key default gen_random_uuid(),
    category_id uuid not null references categories(id) on delete cascade,
    name text not null,
    is_archived boolean not null default false,
    sort_order integer not null default 0,
    created_at timestamptz not null default now(),
    unique (category_id, name)
);

create table if not exists goals (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    kind text not null check (kind in ('reserve', 'deposit', 'custom')),
    name text not null,
    target_amount_minor bigint,
    is_archived boolean not null default false,
    sort_order integer not null default 0,
    created_at timestamptz not null default now(),
    unique (user_id, name)
);

create table if not exists transactions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    type text not null check (type in ('income', 'expense', 'investment', 'goal_allocation', 'refund')),
    amount_minor bigint not null check (amount_minor > 0),
    currency char(3) not null default 'RUB',
    occurred_at timestamptz not null,
    note text,
    category_id uuid references categories(id),
    subcategory_id uuid references subcategories(id),
    goal_id uuid references goals(id),
    linked_transaction_id uuid references transactions(id),
    source text not null default 'mini_app' check (source in ('mini_app', 'bot', 'system')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    deleted_at timestamptz
);

create table if not exists recurring_expenses (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    name text not null,
    category_id uuid not null references categories(id),
    subcategory_id uuid references subcategories(id),
    kind text not null check (kind in ('fixed', 'variable')),
    cadence text not null check (cadence in ('monthly', 'yearly', 'custom')),
    expected_amount_minor bigint,
    day_of_month integer check (day_of_month between 1 and 31),
    is_active boolean not null default true,
    note text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists keyword_rules (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    phrase text not null,
    category_id uuid not null references categories(id),
    subcategory_id uuid references subcategories(id),
    priority integer not null default 100,
    is_active boolean not null default true,
    unique (user_id, phrase)
);

create index if not exists idx_transactions_user_occurred_at
    on transactions(user_id, occurred_at desc)
    where deleted_at is null;

create index if not exists idx_transactions_user_type_occurred_at
    on transactions(user_id, type, occurred_at desc)
    where deleted_at is null;

create index if not exists idx_transactions_linked_transaction_id
    on transactions(linked_transaction_id)
    where deleted_at is null;

create index if not exists idx_categories_user_kind_archived
    on categories(user_id, kind, is_archived);

create index if not exists idx_recurring_expenses_user_active
    on recurring_expenses(user_id, is_active);
