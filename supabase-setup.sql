-- Run this in your Supabase project's SQL Editor (Project -> SQL Editor -> New query)

create table if not exists public.books (
  id            text primary key,
  isbn          text default '',
  title         text not null default '',
  author        text default '',
  cover_url     text default '',
  genres        text[] default '{}',
  total_pages   text default '',
  format        text default 'Paperback',
  read_status   text default 'Unread',
  owner         text default 'Hers',
  rating        int default 0,
  is_series     boolean default false,
  series_name   text default '',
  series_number text default '',
  tags          text[] default '{}',
  review        text default '',
  loaned        boolean default false,
  loaned_to     text default '',
  loaned_date   text default '',
  date_added    text default '',
  updated_at    timestamptz default now()
);

-- keep updated_at fresh on every write (handy for sorting / debugging)
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists books_set_updated_at on public.books;
create trigger books_set_updated_at
  before update on public.books
  for each row execute function public.set_updated_at();

-- Row Level Security: this app uses the public "anon" key directly from
-- the browser with no login, so it's a fully open table by design (fine
-- for a personal library on an artifact only you have the link to).
-- If you want real per-user privacy, add Supabase Auth and swap this
-- policy for one scoped to auth.uid().
alter table public.books enable row level security;

drop policy if exists "public read/write" on public.books;
create policy "public read/write"
  on public.books
  for all
  using (true)
  with check (true);
