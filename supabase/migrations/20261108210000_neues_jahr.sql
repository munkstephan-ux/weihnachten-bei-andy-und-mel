-- Liste fürs nächste Weihnachten vorbereiten: Gäste bleiben, alles andere wird zurückgesetzt.
create or replace function public.neues_jahr() returns void
language plpgsql security definer set search_path = public as $$
begin
  delete from public.antworten where true;
  delete from public.posten where true;
  update public.gaeste set status = 'offen' where true;
  update public.info set datum = '', fleisch = '' where true;
end;
$$;
revoke all on function public.neues_jahr() from public;
grant execute on function public.neues_jahr() to anon, authenticated;
