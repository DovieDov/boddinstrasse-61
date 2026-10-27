-- Deep clean now has three options (no / 30 hours / 60 hours): replaces cast_vote with the new allowed list.
create or replace function public.cast_vote(p_init text, p_opt text, p_name text, p_unit text default null)
returns void language plpgsql security definer set search_path = public as $$
declare
  allowed jsonb := '{"reserve":["10k","20k","30k"],"buzzer":["fix","new","video","none"],"clean":["no","h30","h60"],"door":["fix","new","none"],"legal":["continue","end"],"bikes":["yes","no"],"yard":["yes","no"],"elevator":["yes","no"],"cellar":["yes","no"]}';
  v_name text := btrim(coalesce(p_name, ''));
  v_unit text := nullif(btrim(coalesce(p_unit, '')), '');
begin
  if char_length(v_name) < 1 or char_length(v_name) > 60 then raise exception 'invalid name'; end if;
  if not (allowed ? p_init) or not ((allowed -> p_init) ? p_opt) then raise exception 'invalid vote'; end if;
  if v_unit is not null and char_length(v_unit) > 20 then raise exception 'invalid unit'; end if;
  insert into public.boddinstrasse_61 (init, opt, name, name_key, unit)
  values (p_init, p_opt, v_name, lower(v_name), v_unit)
  on conflict (init, name_key) do update
    set opt = excluded.opt, name = excluded.name, unit = coalesce(excluded.unit, public.boddinstrasse_61.unit), updated_at = now();
end; $$;
