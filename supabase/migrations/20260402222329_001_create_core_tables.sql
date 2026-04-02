/*
  # Create Core Tables for FumiControl SaaS
  
  1. New Tables
    - `tenants` - SaaS companies/organizations
    - `subscription_plans` - Available subscription plans
    - `users` - System users (all levels)
    - `customers` - Clients of fumigation companies
    - `locations` - Properties/sites to be serviced
    - `location_areas` - Specific areas within locations
    
  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users based on tenant_id
    - Admin users can manage their tenant data
    - Users can only see data from their tenant
*/

-- Tenants table (SaaS companies)
CREATE TABLE IF NOT EXISTS tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  slug text UNIQUE NOT NULL,
  logo_url text,
  contact_email text NOT NULL,
  phone text,
  subscription_plan_id uuid,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'trial', 'suspended', 'cancelled')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Subscription plans
CREATE TABLE IF NOT EXISTS subscription_plans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  price_monthly numeric(10,2) NOT NULL DEFAULT 0,
  price_annual numeric(10,2) NOT NULL DEFAULT 0,
  max_locations integer,
  max_users integer,
  max_technicians integer,
  features jsonb DEFAULT '{}',
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);

-- Users table (multi-level)
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES tenants(id) ON DELETE CASCADE,
  email text UNIQUE NOT NULL,
  first_name text NOT NULL,
  last_name text NOT NULL,
  phone text,
  avatar_url text,
  role text NOT NULL CHECK (role IN ('saas_admin', 'company_admin', 'supervisor', 'technician', 'client')),
  status text DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
  created_at timestamptz DEFAULT now(),
  last_login timestamptz
);

-- Customers (clients of fumigation companies)
CREATE TABLE IF NOT EXISTS customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  type text NOT NULL CHECK (type IN ('hotel', 'residential', 'commercial', 'restaurant', 'other')),
  contact_person text,
  email text,
  phone text,
  address text,
  city text,
  state text,
  postal_code text,
  status text DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Locations (properties/sites)
CREATE TABLE IF NOT EXISTS locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  customer_id uuid REFERENCES customers(id) ON DELETE CASCADE,
  name text NOT NULL,
  type text NOT NULL CHECK (type IN ('hotel', 'residential', 'commercial', 'restaurant', 'other')),
  address text NOT NULL,
  city text,
  state text,
  postal_code text,
  coordinates point,
  total_area_sqm numeric(10,2),
  floors integer DEFAULT 1,
  status text DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Location areas (specific zones within a location)
CREATE TABLE IF NOT EXISTS location_areas (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  name text NOT NULL,
  area_type text,
  square_meters numeric(10,2),
  risk_level text CHECK (risk_level IN ('low', 'medium', 'high')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE location_areas ENABLE ROW LEVEL SECURITY;

-- Policies for tenants
CREATE POLICY "SaaS admins can view all tenants"
  ON tenants FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'saas_admin'
    )
  );

CREATE POLICY "Users can view own tenant"
  ON tenants FOR SELECT
  TO authenticated
  USING (
    id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

-- Policies for subscription_plans
CREATE POLICY "Anyone can view subscription plans"
  ON subscription_plans FOR SELECT
  TO authenticated
  USING (true);

-- Policies for users
CREATE POLICY "Users can view users in same tenant"
  ON users FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM users WHERE users.id = auth.uid() AND users.role = 'saas_admin'
    )
  );

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  TO authenticated
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());

-- Policies for customers
CREATE POLICY "Users can view customers in same tenant"
  ON customers FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage customers"
  ON customers FOR ALL
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('saas_admin', 'company_admin', 'supervisor')
    )
  );

-- Policies for locations
CREATE POLICY "Users can view locations in same tenant"
  ON locations FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage locations"
  ON locations FOR ALL
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('saas_admin', 'company_admin', 'supervisor')
    )
  );

-- Policies for location_areas
CREATE POLICY "Users can view location areas in same tenant"
  ON location_areas FOR SELECT
  TO authenticated
  USING (
    location_id IN (
      SELECT id FROM locations 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
  );