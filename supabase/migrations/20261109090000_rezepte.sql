-- Rezepte zu jedem Eintrag
alter table public.posten add column if not exists rezept text not null default '' check (char_length(rezept) <= 8000);
notify pgrst, 'reload schema';
