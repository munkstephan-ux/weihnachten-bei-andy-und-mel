-- Fleischbilanz: Gastgeber tragen nach dem Abend ein, wie viel gekauft und wie viel übrig war.
-- JSON-Text: [{"j":2026,"k":3200,"u":600,"e":12.5}] (Jahr, gekauft g, übrig g, Esser-Einheiten). Bleibt beim neuen Jahr erhalten.
alter table public.info add column if not exists fleischbilanz text not null default '';
