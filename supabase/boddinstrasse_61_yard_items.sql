-- Courtyard improvement is split into four items (yard1..yard4), each voted yes/no on its own and each with its own priority.
-- 'yard' stays allowed in the tables so older rows remain valid, but the page no longer shows it and the functions no longer accept it.
alter table public.boddinstrasse_61 drop constraint if exists boddinstrasse_61_init_check;
alter table public.boddinstrasse_61 add constraint boddinstrasse_61_init_check check (init in ('reserve','buzzer','clean','door','legal','bikes','yard','yard1','yard2','yard3','yard4','elevator','cellar'));
alter table public.boddinstrasse_61_priority drop constraint if exists boddinstrasse_61_priority_init_check;
alter table public.boddinstrasse_61_priority add constraint boddinstrasse_61_priority_init_check check (init in ('reserve','buzzer','clean','door','legal','bikes','yard','yard1','yard2','yard3','yard4','elevator','cellar'));
create or replace function public.cast_vote(p_init text, p_opt text, p_name text, p_unit text default null)
returns void language plpgsql security definer set search_path = public as $$
declare
  allowed jsonb := '{"reserve":["10k","20k","30k"],"buzzer":["fix","new","video","none"],"clean":["no","h30","h60"],"door":["fix","new","none"],"legal":["continue","end"],"bikes":["yes","no"],"yard1":["yes","no"],"yard2":["yes","no"],"yard3":["yes","no"],"yard4":["yes","no"],"elevator":["yes","no"],"cellar":["yes","no"]}';
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
create or replace function public.set_priority(p_init text, p_priority text, p_name text, p_unit text default null)
returns void language plpgsql security definer set search_path = public as $$
declare
  v_name text := btrim(coalesce(p_name, ''));
  v_unit text := nullif(btrim(coalesce(p_unit, '')), '');
begin
  if char_length(v_name) < 1 or char_length(v_name) > 60 then raise exception 'invalid name'; end if;
  if p_init not in ('reserve','buzzer','clean','door','legal','bikes','yard1','yard2','yard3','yard4','elevator','cellar') or p_priority not in ('high','medium','low') then raise exception 'invalid priority'; end if;
  if v_unit is not null and char_length(v_unit) > 20 then raise exception 'invalid unit'; end if;
  insert into public.boddinstrasse_61_priority (init, priority, name, name_key, unit)
  values (p_init, p_priority, v_name, lower(v_name), v_unit)
  on conflict (init, name_key) do update
    set priority = excluded.priority, name = excluded.name, unit = coalesce(excluded.unit, public.boddinstrasse_61_priority.unit), updated_at = now();
end; $$;
