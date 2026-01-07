-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create Enum for Booking Status
create type booking_status as enum ('pending', 'confirmed', 'denied');

-- 1. Bookings Table (Updated)
create table bookings (
  id uuid default uuid_generate_v4() primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  date timestamp with time zone not null, -- The start time of the appointment
  customer_name text not null,
  customer_phone text not null,
  customer_email text not null,
  status booking_status default 'pending'::booking_status,
  
  constraint valid_email check (customer_email ~* '^[A-Za-z0-9._+%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
);

-- 2. Barber Settings (Singleton Table)
-- Stores global configuration like max cuts per day
create table barber_settings (
  id int primary key default 1, -- Force single row
  max_cuts_per_day int default 10,
  slot_duration_minutes int default 60,
  auto_approve boolean default false,
  constraint single_row check (id = 1)
);

-- Initialize default settings
insert into barber_settings (id, max_cuts_per_day) values (1, 10) on conflict do nothing;

-- 3. Default Weekly Schedule
-- Stores the recurring availability (e.g., every Tuesday 4pm-8pm)
create table weekly_schedule (
  id uuid default uuid_generate_v4() primary key,
  day_of_week int not null, -- 1=Sunday, 2=Monday, ... 7=Saturday
  start_hour int not null, -- e.g., 16 for 4pm
  end_hour int not null,   -- e.g., 20 for 8pm
  is_active boolean default true,
  
  constraint valid_day check (day_of_week between 1 and 7),
  constraint valid_hours check (start_hour >= 0 and end_hour <= 24 and start_hour < end_hour),
  unique(day_of_week) -- One rule per day for simplicity (can be expanded)
);

-- Seed Initial Schedule (Tue-Sat, 4pm-8pm) based on previous hardcoded values
insert into weekly_schedule (day_of_week, start_hour, end_hour) values 
(3, 16, 20), -- Tuesday
(4, 16, 20), -- Wednesday
(5, 16, 20), -- Thursday
(6, 16, 20), -- Friday
(7, 16, 20); -- Saturday

-- 4. Calendar Overrides / Blocks
-- Specific dates where Ryan is totally unavailable or has custom hours
create table schedule_overrides (
  id uuid default uuid_generate_v4() primary key,
  date date not null, -- Specific date (e.g., 2025-12-25)
  is_blocked boolean default true, -- If true, no cuts that day
  start_hour int, -- Optional: if not blocked, define custom hours
  end_hour int
);

-- RLS Policies (Security)
alter table bookings enable row level security;
alter table barber_settings enable row level security;
alter table weekly_schedule enable row level security;
alter table schedule_overrides enable row level security;

-- Public Access (Client App)
create policy "Public can insert bookings" on bookings for insert with check (true);
create policy "Public can view own bookings" on bookings for select using (true); -- Simplify for now
create policy "Public can read settings" on barber_settings for select using (true);
create policy "Public can read schedule" on weekly_schedule for select using (true);
create policy "Public can read overrides" on schedule_overrides for select using (true);

-- Admin Access (Ryan) - Placeholder using 'authenticated' role
-- Ideally, you'd check email or specific user ID
create policy "Admin full access bookings" on bookings for all using (auth.role() = 'authenticated');
create policy "Admin full access settings" on barber_settings for all using (auth.role() = 'authenticated');
create policy "Admin full access schedule" on weekly_schedule for all using (auth.role() = 'authenticated');
create policy "Admin full access overrides" on schedule_overrides for all using (auth.role() = 'authenticated');

-- Realtime
alter publication supabase_realtime add table bookings;
alter publication supabase_realtime add table barber_settings;
alter publication supabase_realtime add table weekly_schedule;
alter publication supabase_realtime add table schedule_overrides;