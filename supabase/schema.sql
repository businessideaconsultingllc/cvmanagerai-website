-- Create a table for public profiles
create table profiles (
  id uuid references auth.users not null primary key,
  first_name text,
  last_name text,
  email text,
  phone text,
  address text,
  credits_balance int default 5,
  last_credit_reset timestamp with time zone default now(),
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Set up Row Level Security (RLS)
alter table profiles enable row level security;

create policy "Public profiles are viewable by everyone." on profiles
  for select using (true);

create policy "Users can insert their own profile." on profiles
  for insert with check (auth.uid() = id);

create policy "Users can update own profile." on profiles
  for update using (auth.uid() = id);

-- Create a table for CVs
create table cvs (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id) not null,
  title text not null,
  content jsonb, -- Stores the structured CV data
  language text default 'en',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Set up RLS for CVs
alter table cvs enable row level security;

create policy "Users can view their own CVs." on cvs
  for select using (auth.uid() = user_id);

create policy "Users can insert their own CVs." on cvs
  for insert with check (auth.uid() = user_id);

create policy "Users can update their own CVs." on cvs
  for update using (auth.uid() = user_id);

create policy "Users can delete their own CVs." on cvs
  for delete using (auth.uid() = user_id);

-- Function to handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, first_name, last_name)
  values (new.id, new.email, '', '');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger the function every time a user is created
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
