-- The doctor sets the patient's next visit from the dashboard.
alter table public.patients add column if not exists next_visit date;
create policy "doctor updates follow-up" on public.patients for update
  using (public.is_doctor()) with check (public.is_doctor());
alter publication supabase_realtime add table public.checks, public.shares;
