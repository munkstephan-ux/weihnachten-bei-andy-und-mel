-- Sitzordnung an der Tafel: von den Gastgebern festgelegt, als JSON {Platz: Person} (z. B. {"L1":"andreas|Andy"}).
alter table public.info add column if not exists sitzplan text not null default '';
