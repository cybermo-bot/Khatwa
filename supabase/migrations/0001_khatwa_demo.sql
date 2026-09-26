-- Khatwa demo data model (Supabase, Postgres 15).
-- Patients sign in anonymously (Supabase anonymous sign-in); doctors with email.
-- The compute server writes scans and findings with the service role key.
-- Demo only: no names, no national ID numbers; audience data is wiped after the event.

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- people

create table if not exists public.doctors (
  user_id uuid primary key references auth.users on delete cascade,
  display_name text not null,             -- "Dr Demo, Endocrinologie"
  created_at timestamptz not null default now()
);

create table if not exists public.patients (
  id uuid primary key default gen_random_uuid(),
  ref text unique not null check (ref ~ '^[a-z0-9-]{6,64}$'),  -- also the FHIR Patient id
  owner uuid references auth.users on delete set null,        -- the patient's (anonymous) login
  display_name text not null,             -- pseudonym only, e.g. "Patient 07"
  is_demo boolean not null default false, -- seeded synthetic patient
  age int check (age between 1 and 120),
  sex text check (sex in ('F', 'M')),
  diabetes_type text check (diabetes_type in ('1', '2', 'other')),
  governorate text,                       -- one of the 24 Tunisian governorates
  iwgdf_risk int check (iwgdf_risk between 0 and 3),
  last_check text check (last_check in ('green', 'amber', 'red')),
  shared_with_doctor boolean not null default false,
  created_at timestamptz not null default now(),
  last_active_at timestamptz not null default now()
);

-- ---------------------------------------------------------------- twin

create table if not exists public.scans (
  id text primary key,                    -- server scan id
  patient_id uuid not null references public.patients on delete cascade,
  side text not null check (side in ('L', 'R')),
  created_at timestamptz not null default now(),
  measurements jsonb not null,            -- foot_length_mm ... volume_to_8cm_ml; null = not measured
  quality jsonb not null default '{}',
  glb_path text not null,                 -- storage: twins/<patient_id>/<scan_id>.glb
  sole_photo_path text,                   -- storage: photos/<patient_id>/<photo_id>.jpg once the sole is mapped
  sole_textured boolean not null default false
);

create table if not exists public.findings (
  id text primary key,
  patient_id uuid not null references public.patients on delete cascade,
  side text not null check (side in ('L', 'R')),
  day date not null,
  kind text not null,                     -- callus, corn, blister, wound, redness, swelling, colour, ... unsure
  region text not null,                   -- hallux, lesser_toes, interdigital, forefoot_plantar, midfoot_plantar,
                                          -- heel_plantar, heel_posterior, dorsum, medial_side, lateral_side, ankle
  vertex int not null,                    -- twin vertex: same anatomical spot at every visit
  area_mm2 real,
  level text not null check (level in ('none', 'soon', 'urgent')),   -- from the triage table
  status text not null default 'new',     -- new, worse, no_improvement, still_there, healed, reported_healed, not_seen
  source text not null default 'photo',   -- photo, sole_photo, twin_tap, clinician
  reporter text not null default 'patient',
  photo_path text,
  note text default '',
  reviewed_by uuid references auth.users,
  created_at timestamptz not null default now()
);

-- ---------------------------------------------------------------- daily life

create table if not exists public.checks (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients on delete cascade,
  day date not null,
  result text not null check (result in ('green', 'amber', 'red')),
  answers jsonb not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.alerts (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients on delete cascade,
  level text not null check (level in ('info', 'soon', 'urgent')),
  source text not null check (source in ('voice', 'finding', 'check', 'scan', 'share')),
  title text not null,                    -- French, short: "Orteil noirci signalé"
  body text not null default '',
  acknowledged_by uuid references auth.users,
  created_at timestamptz not null default now()
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients on delete cascade,
  sender text not null check (sender in ('doctor', 'patient')),
  body text not null check (length(body) <= 2000),
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.shares (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients on delete cascade,
  fhir jsonb not null,                    -- the FHIR R4 Bundle sent to the doctor
  gazelle_report text,                    -- EVS Client result summary, when validated
  created_at timestamptz not null default now()
);

create table if not exists public.app_config (
  key text primary key,                   -- 'server_url': the compute server's current public address
  value text not null,
  updated_at timestamptz not null default now()
);

-- ---------------------------------------------------------------- access rules

create or replace function public.is_doctor() returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.doctors where user_id = auth.uid()) $$;

create or replace function public.owns_patient(p uuid) returns boolean
language sql stable security definer set search_path = public as
$$ select exists (select 1 from public.patients where id = p and owner = auth.uid()) $$;

alter table public.doctors enable row level security;
alter table public.patients enable row level security;
alter table public.scans enable row level security;
alter table public.findings enable row level security;
alter table public.checks enable row level security;
alter table public.alerts enable row level security;
alter table public.messages enable row level security;
alter table public.shares enable row level security;
alter table public.app_config enable row level security;

create policy "doctor reads self" on public.doctors for select using (user_id = auth.uid());

create policy "patient manages own record" on public.patients for all
  using (owner = auth.uid()) with check (owner = auth.uid());
create policy "doctor reads patients" on public.patients for select using (public.is_doctor());

-- Patient: everything about themselves. Doctor: read all, acknowledge and review.
do $$
declare t text;
begin
  foreach t in array array['scans', 'findings', 'checks', 'alerts', 'messages', 'shares'] loop
    execute format('create policy "patient owns %1$s" on public.%1$I for all using (public.owns_patient(patient_id)) with check (public.owns_patient(patient_id))', t);
    execute format('create policy "doctor reads %1$s" on public.%1$I for select using (public.is_doctor())', t);
  end loop;
end $$;

create policy "doctor acknowledges alerts" on public.alerts for update using (public.is_doctor()) with check (public.is_doctor());
create policy "doctor reviews findings" on public.findings for update using (public.is_doctor()) with check (public.is_doctor());
create policy "doctor writes messages" on public.messages for insert with check (public.is_doctor() and sender = 'doctor');

create policy "anyone reads config" on public.app_config for select using (true);

-- ---------------------------------------------------------------- storage

insert into storage.buckets (id, name, public) values ('twins', 'twins', false), ('photos', 'photos', false)
on conflict (id) do nothing;

-- Files live under <patient_id>/...: the owner and doctors may read them.
create policy "read own or as doctor" on storage.objects for select using (
  bucket_id in ('twins', 'photos')
  and (public.is_doctor() or public.owns_patient(((storage.foldername(name))[1])::uuid))
);

-- ---------------------------------------------------------------- live updates

alter publication supabase_realtime add table public.alerts, public.messages, public.scans, public.findings, public.patients;

create index if not exists scans_patient on public.scans (patient_id, created_at desc);
create index if not exists findings_patient on public.findings (patient_id, created_at desc);
create index if not exists alerts_recent on public.alerts (created_at desc);
