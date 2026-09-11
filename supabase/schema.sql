-- Text-only consultation board. No file/image columns and no Supabase Storage usage.
create extension if not exists pgcrypto;
create table if not exists public.consultation_questions (
  id uuid primary key default gen_random_uuid(), public_code text unique not null,
  nickname text not null, source text not null, ai_tool text, search_topic text not null,
  question text not null, pin_hash text not null, is_price boolean not null default false,
  status text not null default 'pending' check (status in ('pending','answered')),
  visibility text not null default 'private' check (visibility in ('public','private')),
  answer text, created_at timestamptz not null default now(), answered_at timestamptz
);
create table if not exists public.consultation_admins (user_id uuid primary key references auth.users(id) on delete cascade);
alter table public.consultation_questions enable row level security;
alter table public.consultation_admins enable row level security;
create or replace function public.is_consultation_admin() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from public.consultation_admins a where a.user_id=auth.uid())$$;
create policy "admin read" on public.consultation_questions for select to authenticated using (public.is_consultation_admin());
create policy "admin update" on public.consultation_questions for update to authenticated using (public.is_consultation_admin()) with check (public.is_consultation_admin());
create or replace function public.create_consultation(p_nickname text,p_source text,p_ai_tool text,p_search_topic text,p_question text,p_pin text) returns text language plpgsql security definer set search_path=public as $$
declare v_code text; v_price boolean;
begin
 if length(trim(p_question))<2 or length(p_question)>1200 then raise exception 'invalid question'; end if;
 if p_pin !~ '^[0-9]{4,8}$' then raise exception 'invalid pin'; end if;
 v_code := upper(substr(replace(gen_random_uuid()::text,'-',''),1,8));
 v_price := p_question ~* '(가격|비용|얼마|금액|만원|원\\s|견적)';
 insert into public.consultation_questions(public_code,nickname,source,ai_tool,search_topic,question,pin_hash,is_price,visibility)
 values(v_code,left(trim(p_nickname),20),left(trim(p_source),50),nullif(left(trim(coalesce(p_ai_tool,'')),50),''),left(trim(p_search_topic),80),trim(p_question),crypt(p_pin,gen_salt('bf')),v_price,'private');
 return v_code;
end$$;
grant execute on function public.create_consultation(text,text,text,text,text,text) to anon,authenticated;
create or replace function public.get_public_consultations() returns table(public_code text,nickname text,question text,answer text,created_at timestamptz,answered_at timestamptz) language sql security definer set search_path=public as $$select q.public_code,q.nickname,q.question,q.answer,q.created_at,q.answered_at from public.consultation_questions q where q.status='answered' and q.visibility='public' and q.is_price=false order by q.answered_at desc limit 50$$;
grant execute on function public.get_public_consultations() to anon,authenticated;
create or replace function public.get_private_consultation(p_code text,p_pin text) returns table(question text,answer text,status text,created_at timestamptz,answered_at timestamptz) language sql security definer set search_path=public as $$select q.question,q.answer,q.status,q.created_at,q.answered_at from public.consultation_questions q where q.public_code=upper(trim(p_code)) and q.pin_hash=crypt(p_pin,q.pin_hash) limit 1$$;
grant execute on function public.get_private_consultation(text,text) to anon,authenticated;
