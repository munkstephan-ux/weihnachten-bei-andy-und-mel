-- Fleisch-Vorlieben: eine Zeile pro Person (nicht pro Haushalt), damit Alex und Sarah sich nicht gegenseitig überschreiben.
-- Bleibt beim „Neues Jahr vorbereiten“ erhalten: Geschmack ändert sich selten.
create table if not exists public.fleisch (
  id text primary key,
  gast text not null,
  person text not null default '',
  menge text not null default 'normal' check (menge in ('wenig','normal','viel')),
  sorte text not null default 'beides' check (sorte in ('rind','beides','schwein')),
  art text not null default 'beides' check (art in ('stein','beides','fondue')),
  t bigint not null default 0
);

alter table public.fleisch enable row level security;
create policy "alle lesen fleisch" on public.fleisch for select to anon, authenticated using (true);
create policy "alle schreiben fleisch" on public.fleisch for all to anon, authenticated using (true) with check (true);

alter publication supabase_realtime add table public.fleisch;
