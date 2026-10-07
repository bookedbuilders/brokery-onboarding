-- Onboardings: one row per customer. Admins (Joe, Landon) are Supabase Auth users.
-- Customers never log in: their magic link carries a token, and they reach the row
-- only through the three functions below.

create extension if not exists pgcrypto;

create table public.onboardings (
  id           uuid primary key default gen_random_uuid(),
  token        text unique not null default encode(gen_random_bytes(12), 'hex'),
  business     text not null,
  contact_name text not null,
  contact_title text,
  prefill      jsonb not null default '{}'::jsonb,   -- fb, ig, site, dns, legal, addr, phone, systems
  raw          jsonb not null default '{}'::jsonb,   -- the survey's own state, so the customer can resume
  answers      jsonb not null default '[]'::jsonb,   -- rendered, in screen order: [{s:label, v:value, ok:bool, sec:section}]
  follow_up    jsonb not null default '[]'::jsonb,
  progress     jsonb not null default '{"done":0,"total":0}'::jsonb,
  setup_call   text,
  submitted_at timestamptz,
  created_by   uuid references auth.users(id) default auth.uid(),
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

alter table public.onboardings enable row level security;

create policy "admins read"   on public.onboardings for select to authenticated using (true);
create policy "admins insert" on public.onboardings for insert to authenticated with check (true);
create policy "admins update" on public.onboardings for update to authenticated using (true) with check (true);
create policy "admins delete" on public.onboardings for delete to authenticated using (true);

revoke all on public.onboardings from anon;
grant select, insert, update, delete on public.onboardings to authenticated, service_role;

-- Customer: load by token
create or replace function public.onboarding_load(t text)
returns jsonb language sql security definer set search_path = public stable as $$
  select jsonb_build_object(
    'business', business, 'contact_name', contact_name, 'contact_title', contact_title,
    'prefill', prefill, 'raw', raw, 'setup_call', setup_call, 'submitted_at', submitted_at)
  from public.onboardings where token = t;
$$;

-- Customer: autosave after every screen
create or replace function public.onboarding_save(t text, r jsonb, a jsonb, f jsonb, p jsonb, w text)
returns void language sql security definer set search_path = public as $$
  update public.onboardings
     set raw = r, answers = a, follow_up = f, progress = p, setup_call = w, updated_at = now()
   where token = t;
$$;

-- Customer: submit
create or replace function public.onboarding_submit(t text, r jsonb, a jsonb, f jsonb, p jsonb, w text)
returns void language sql security definer set search_path = public as $$
  update public.onboardings
     set raw = r, answers = a, follow_up = f, progress = p, setup_call = w,
         submitted_at = now(), updated_at = now()
   where token = t;
$$;

revoke all on function public.onboarding_load(text) from public;
revoke all on function public.onboarding_save(text, jsonb, jsonb, jsonb, jsonb, text) from public;
revoke all on function public.onboarding_submit(text, jsonb, jsonb, jsonb, jsonb, text) from public;
grant execute on function public.onboarding_load(text) to anon, authenticated;
grant execute on function public.onboarding_save(text, jsonb, jsonb, jsonb, jsonb, text) to anon, authenticated;
grant execute on function public.onboarding_submit(text, jsonb, jsonb, jsonb, jsonb, text) to anon, authenticated;
