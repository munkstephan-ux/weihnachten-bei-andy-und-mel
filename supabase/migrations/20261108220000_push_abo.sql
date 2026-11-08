-- Push-Abos über Funktionen speichern/entfernen, ohne dass jemand die Abo-Liste lesen kann.
create or replace function public.push_abo(p_endpoint text, p_sub jsonb, p_gast text) returns void
language sql security definer set search_path = public as $$
  insert into public.push_subs (endpoint, sub, gast) values (p_endpoint, p_sub, coalesce(p_gast, ''))
  on conflict (endpoint) do update set sub = excluded.sub, gast = excluded.gast;
$$;
create or replace function public.push_abmelden(p_endpoint text) returns void
language sql security definer set search_path = public as $$
  delete from public.push_subs where endpoint = p_endpoint;
$$;
revoke all on function public.push_abo(text, jsonb, text) from public;
revoke all on function public.push_abmelden(text) from public;
grant execute on function public.push_abo(text, jsonb, text) to anon, authenticated;
grant execute on function public.push_abmelden(text) to anon, authenticated;
-- Direkter Tabellenzugriff wird nicht mehr gebraucht.
drop policy if exists "abo eintragen" on public.push_subs;
drop policy if exists "abo aktualisieren" on public.push_subs;
drop policy if exists "abo loeschen" on public.push_subs;
