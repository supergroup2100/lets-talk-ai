-- 明信片大作戰 Postcard Battle：Supabase 建表 SQL
-- 到 Supabase Dashboard > SQL Editor > New query，貼上整段按 Run
-- 課文：Dialogue (Jenny and Tina / Postcrossing) / 單字：postcard, famous, beautiful, piece of cake, keep in touch, late, tomorrow

-- 1. 每一場對戰（一堂課可能多場）
create table if not exists public.postcard_sessions (
  id uuid primary key default gen_random_uuid(),
  class_name text not null default '',
  lesson text not null default 'Dialogue: Jenny and Tina (Postcrossing)',
  teams jsonb not null default '[]',
  winner text not null default '',
  created_at timestamptz not null default now()
);

-- 2. 每一題作答歷程（誰、哪一隊、哪一回合、對錯、花幾秒）
create table if not exists public.postcard_events (
  id bigint generated always as identity primary key,
  session_id uuid references public.postcard_sessions(id) on delete cascade,
  team text not null,
  player text not null default '',
  round text not null,
  qid text not null,
  correct boolean not null,
  ms integer not null default 0,
  pts integer not null default 0,
  created_at timestamptz not null default now()
);

-- 3. 老師看板：各隊答對率（建完表自動可用）
create or replace view public.postcard_scoreboard as
select session_id, team,
  count(*) as answered,
  count(*) filter (where correct) as hits,
  round(count(*) filter (where correct)::numeric / greatest(count(*),1) * 100, 1) as hit_rate,
  avg(ms)::int as avg_ms,
  sum(pts) as total_pts
from public.postcard_events
group by session_id, team;

-- 4. 錯題回顧：哪幾題錯最多（備課用）
create or replace view public.postcard_mistakes as
select session_id, round, qid,
  count(*) as answered,
  count(*) filter (where not correct) as mistakes
from public.postcard_events
group by session_id, round, qid
order by mistakes desc;

-- 5. RLS：教室情境，允許匿名新增＋查詢（正式使用請再縮限）
alter table public.postcard_sessions enable row level security;
alter table public.postcard_events enable row level security;

drop policy if exists "anon read postcard sessions" on public.postcard_sessions;
create policy "anon read postcard sessions" on public.postcard_sessions for select to anon using (true);
drop policy if exists "anon insert postcard sessions" on public.postcard_sessions;
create policy "anon insert postcard sessions" on public.postcard_sessions for insert to anon with check (true);

drop policy if exists "anon read postcard events" on public.postcard_events;
create policy "anon read postcard events" on public.postcard_events for select to anon using (true);
drop policy if exists "anon insert postcard events" on public.postcard_events;
create policy "anon insert postcard events" on public.postcard_events for insert to anon with check (true);
