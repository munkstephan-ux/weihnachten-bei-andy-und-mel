-- Weihnachten bei Andreas: gemeinsame Mitbringliste (ohne Konten, Zugriff über den öffentlichen App-Schlüssel)
create table if not exists public.info (
  id text primary key,
  datum text not null default '',
  fleisch text not null default ''
);
create table if not exists public.gaeste (
  id text primary key,
  name text not null default '',
  erw int not null default 1,
  kinder int not null default 0,
  status text not null default 'offen' check (status in ('ja','offen','nein')),
  t bigint not null default 0
);
create table if not exists public.posten (
  id text primary key,
  kat text not null,
  name text not null default '',
  wer text not null default '',
  von text not null default '',
  likes text[] not null default '{}',
  t bigint not null default 0
);
create table if not exists public.antworten (
  id text primary key,
  posten text not null references public.posten(id) on delete cascade,
  von text not null default '',
  inhalt text not null default '' check (char_length(inhalt) <= 1000),
  t bigint not null default 0
);
create table if not exists public.push_subs (
  endpoint text primary key,
  sub jsonb not null,
  gast text not null default '',
  created_at timestamptz not null default now()
);

alter table public.info enable row level security;
alter table public.gaeste enable row level security;
alter table public.posten enable row level security;
alter table public.antworten enable row level security;
alter table public.push_subs enable row level security;

-- Die Familie liest und schreibt die Liste ohne Anmeldung.
create policy "alle lesen info" on public.info for select to anon, authenticated using (true);
create policy "alle schreiben info" on public.info for all to anon, authenticated using (true) with check (true);
create policy "alle lesen gaeste" on public.gaeste for select to anon, authenticated using (true);
create policy "alle schreiben gaeste" on public.gaeste for all to anon, authenticated using (true) with check (true);
create policy "alle lesen posten" on public.posten for select to anon, authenticated using (true);
create policy "alle schreiben posten" on public.posten for all to anon, authenticated using (true) with check (true);
create policy "alle lesen antworten" on public.antworten for select to anon, authenticated using (true);
create policy "alle schreiben antworten" on public.antworten for all to anon, authenticated using (true) with check (true);
-- Push-Abos: eintragen, aktualisieren und löschen ja, aber niemand kann die Liste der Abos auslesen.
create policy "abo eintragen" on public.push_subs for insert to anon, authenticated with check (true);
create policy "abo aktualisieren" on public.push_subs for update to anon, authenticated using (true) with check (true);
create policy "abo loeschen" on public.push_subs for delete to anon, authenticated using (true);

-- "Hab Lust drauf" ohne Überschreiben bei gleichzeitigen Klicks
create or replace function public.toggle_like(p_id text, g_id text) returns void
language sql security invoker set search_path = public as $$
  update public.posten
     set likes = case when g_id = any(likes) then array_remove(likes, g_id) else array_append(likes, g_id) end
   where id = p_id;
$$;
grant execute on function public.toggle_like(text, text) to anon, authenticated;

-- Live-Aktualisierung
alter publication supabase_realtime add table public.info, public.gaeste, public.posten, public.antworten;
