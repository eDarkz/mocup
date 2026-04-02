/*
  # Create Service Management Tables
  
  1. New Tables
    - `contracts` - Service contracts between customers and companies
    - `quotes` - Service quotations
    - `service_orders` - Work orders for fumigation services
    - `fumigations` - Actual fumigation service records
    - `service_requests` - Customer service requests
    
  2. Security
    - Enable RLS on all tables
    - Add policies for tenant-based access
*/

-- Contracts
CREATE TABLE IF NOT EXISTS contracts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  contract_number text UNIQUE NOT NULL,
  start_date date NOT NULL,
  end_date date,
  service_type text NOT NULL,
  frequency text CHECK (frequency IN ('monthly', 'quarterly', 'semi-annual', 'annual', 'one-time')),
  billing_amount numeric(10,2) NOT NULL DEFAULT 0,
  status text DEFAULT 'active' CHECK (status IN ('draft', 'active', 'expired', 'cancelled')),
  terms text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Quotes/Quotations
CREATE TABLE IF NOT EXISTS quotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  quote_number text UNIQUE NOT NULL,
  title text NOT NULL,
  description text,
  total_amount numeric(10,2) NOT NULL DEFAULT 0,
  valid_until date,
  services jsonb DEFAULT '[]',
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'accepted', 'rejected', 'expired')),
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Service Orders
CREATE TABLE IF NOT EXISTS service_orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  contract_id uuid REFERENCES contracts(id) ON DELETE SET NULL,
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  order_number text UNIQUE NOT NULL,
  service_type text NOT NULL CHECK (service_type IN ('scheduled', 'emergency', 'inspection', 'extra')),
  scheduled_date date NOT NULL,
  scheduled_time time,
  duration_hours numeric(4,2),
  technician_id uuid REFERENCES users(id),
  supervisor_id uuid REFERENCES users(id),
  priority text DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'assigned', 'in_progress', 'completed', 'pending_approval', 'approved', 'cancelled')),
  special_instructions text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  started_at timestamptz,
  completed_at timestamptz
);

-- Fumigations (actual service execution records)
CREATE TABLE IF NOT EXISTS fumigations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  service_order_id uuid NOT NULL REFERENCES service_orders(id) ON DELETE CASCADE,
  technician_id uuid NOT NULL REFERENCES users(id),
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  check_in_time timestamptz,
  check_out_time timestamptz,
  areas_treated jsonb DEFAULT '[]',
  pests_targeted jsonb DEFAULT '[]',
  treatments_applied jsonb DEFAULT '[]',
  chemicals_used jsonb DEFAULT '[]',
  observations text,
  photos jsonb DEFAULT '[]',
  client_signature_url text,
  client_name text,
  status text DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'pending_review')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Service Requests (from clients)
CREATE TABLE IF NOT EXISTS service_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  requested_by uuid REFERENCES users(id),
  request_type text NOT NULL CHECK (request_type IN ('regular', 'emergency', 'extra', 'inspection')),
  description text NOT NULL,
  preferred_date date,
  priority text DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'scheduled', 'completed', 'rejected')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE fumigations ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;

-- Policies for contracts
CREATE POLICY "Users can view contracts in same tenant"
  ON contracts FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

-- Policies for quotes
CREATE POLICY "Users can view quotes in same tenant"
  ON quotes FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

-- Policies for service_orders
CREATE POLICY "Users can view service orders in same tenant"
  ON service_orders FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
    OR
    technician_id = auth.uid()
    OR
    supervisor_id = auth.uid()
  );

CREATE POLICY "Technicians can update assigned service orders"
  ON service_orders FOR UPDATE
  TO authenticated
  USING (technician_id = auth.uid())
  WITH CHECK (technician_id = auth.uid());

-- Policies for fumigations
CREATE POLICY "Users can view fumigations in same tenant"
  ON fumigations FOR SELECT
  TO authenticated
  USING (
    location_id IN (
      SELECT id FROM locations 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
    OR
    technician_id = auth.uid()
  );

CREATE POLICY "Technicians can create fumigations"
  ON fumigations FOR INSERT
  TO authenticated
  WITH CHECK (technician_id = auth.uid());

CREATE POLICY "Technicians can update own fumigations"
  ON fumigations FOR UPDATE
  TO authenticated
  USING (technician_id = auth.uid())
  WITH CHECK (technician_id = auth.uid());

-- Policies for service_requests
CREATE POLICY "Users can view service requests in same tenant"
  ON service_requests FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );