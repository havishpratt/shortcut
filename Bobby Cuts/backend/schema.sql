-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Enum for Booking Status
create type booking_status as enum ('pending', 'confirmed', 'denied');

-- 1. Bookings Table
create table bookings (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  date timestamp with time zone not null,
  customer_name text not null,
  customer_phone text not null,
  customer_email text not null,
  status booking_status default 'pending'::booking_status,
  
  constraint valid_email check (customer_email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

-- 2. Barber Settings (Singleton Table)
create table barber_settings (
  id int primary key default 1,
  max_cuts_per_day int default 10,
  slot_duration_minutes int default 60,
  auto_approve boolean default false,
  constraint single_row check (id = 1)
);
insert into barber_settings (id, max_cuts_per_day) values (1, 10) on conflict do nothing;

-- 3. Weekly Schedule
create table weekly_schedule (
  id uuid default uuid_generate_v4() primary key,
  day_of_week int not null,
  start_hour int not null,
  end_hour int not null,
  is_active boolean default true,
  constraint valid_day check (day_of_week between 1 and 7),
  constraint valid_hours check (start_hour >= 0 and end_hour <= 24 and start_hour < end_hour),
  unique(day_of_week)
);
insert into weekly_schedule (day_of_week, start_hour, end_hour) values 
(3, 16, 20), (4, 16, 20), (5, 16, 20), (6, 16, 20), (7, 16, 20)
on conflict do nothing;

-- 4. PROFILES (New!) - Stores user roles
create table public.profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  is_admin boolean default false
);

-- 5. Trigger to Auto-Create Profile on Signup
-- This function runs automatically whenever a new user is created in Supabase Auth
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, email, is_admin)
  values (new.id, new.email, false); -- Default to FALSE (not admin)
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- RLS Policies (Updated)
alter table bookings enable row level security;
alter table barber_settings enable row level security;
alter table weekly_schedule enable row level security;
alter table profiles enable row level security;

-- Public Access
create policy "Public can insert bookings" on bookings for insert with check (true);
create policy "Public can view own bookings" on bookings for select using (true);
create policy "Public can read settings" on barber_settings for select using (true);
create policy "Public can read schedule" on weekly_schedule for select using (true);

-- Profiles Access
create policy "Users can read own profile" on profiles for select using (auth.uid() = id);

-- ADMIN POLICIES (The "Ryan" Access)
-- Check if the current user has is_admin = true in their profile
create policy "Admins can do everything on bookings" on bookings for all 
using (exists (select 1 from profiles where id = auth.uid() and is_admin = true));

create policy "Admins can update settings" on barber_settings for update
using (exists (select 1 from profiles where id = auth.uid() and is_admin = true));

create policy "Admins can update schedule" on weekly_schedule for update
using (exists (select 1 from profiles where id = auth.uid() and is_admin = true));
