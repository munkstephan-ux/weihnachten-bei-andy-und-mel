-- Film-Look (20.11.2026): „Keins“ als Antwort auf „Wie viel Fleisch?“ (zählt 0 g, Folgefragen entfallen).
-- Enthält zur Sicherheit auch die Fleischbilanz-Spalte aus 20261119120000 (falls die noch nicht lief).
-- Die App schaltet „Keins“ und die Bilanz erst frei, wenn info.fleischbilanz existiert.
alter table public.info add column if not exists fleischbilanz text not null default '';
alter table public.fleisch drop constraint if exists fleisch_menge_check;
alter table public.fleisch add constraint fleisch_menge_check check (menge in ('kein','wenig','normal','viel'));
