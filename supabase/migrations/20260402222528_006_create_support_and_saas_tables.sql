/*
  # Create Support and SaaS Management Tables
  
  1. New Tables
    - `alerts` - System alerts and notifications
    - `audit_logs` - Audit trail for compliance
    - `support_tickets` - Customer support tickets
    - `feature_flags` - Feature flag management
    - `tenant_features` - Tenant-specific feature enablement
    - `vehicles` - Fleet management
    
  2. Security
    - Enable RLS on all tables
    - Role-based access control
*/

-- Alerts and notifications
CREATE TABLE IF NOT EXISTS alerts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  alert_type text NOT NULL CHECK (alert_type IN ('stock_critical', 'pest_activity', 'equipment_issue', 'technician_delay', 'service_overdue', 'payment_overdue')),
  severity text DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  title text NOT NULL,
  message text NOT NULL,
  source_type text,
  source_id uuid,
  is_read boolean DEFAULT false,
  acknowledged_by uuid REFERENCES users(id),
  acknowledged_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Audit logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES tenants(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id),
  action text NOT NULL,
  resource_type text NOT NULL,
  resource_id uuid,
  old_value jsonb,
  new_value jsonb,
  ip_address text,
  user_agent text,
  created_at timestamptz DEFAULT now()
);

-- Support tickets
CREATE TABLE IF NOT EXISTS support_tickets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  created_by uuid REFERENCES users(id),
  subject text NOT NULL,
  description text NOT NULL,
  category text CHECK (category IN ('technical', 'billing', 'general', 'feature_request', 'bug')),
  priority text DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
  status text DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'waiting_response', 'resolved', 'closed')),
  assigned_to uuid REFERENCES users(id),
  resolved_at timestamptz,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Feature flags (SaaS level)
CREATE TABLE IF NOT EXISTS feature_flags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  feature_name text UNIQUE NOT NULL,
  description text,
  is_enabled boolean DEFAULT false,
  rollout_percentage integer DEFAULT 0 CHECK (rollout_percentage >= 0 AND rollout_percentage <= 100),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tenant-specific feature enablement
CREATE TABLE IF NOT EXISTS tenant_features (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  feature_flag_id uuid NOT NULL REFERENCES feature_flags(id) ON DELETE CASCADE,
  is_enabled boolean DEFAULT false,
  enabled_at timestamptz,
  enabled_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  UNIQUE(tenant_id, feature_flag_id)
);

-- Vehicles
CREATE TABLE IF NOT EXISTS vehicles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  plate_number text UNIQUE NOT NULL,
  make text NOT NULL,
  model text NOT NULL,
  year integer,
  vin text UNIQUE,
  purchase_date date,
  current_technician_id uuid REFERENCES users(id),
  gps_device_id text,
  status text DEFAULT 'active' CHECK (status IN ('active', 'maintenance', 'inactive', 'decommissioned')),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE vehicles ENABLE ROW LEVEL SECURITY;

-- Policies for alerts
CREATE POLICY "Users can view alerts in same tenant"
  ON alerts FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

CREATE POLICY "Users can acknowledge alerts"
  ON alerts FOR UPDATE
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  )
  WITH CHECK (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

-- Policies for audit_logs
CREATE POLICY "SaaS admins can view all audit logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'saas_admin'
    )
  );

CREATE POLICY "Company admins can view tenant audit logs"
  ON audit_logs FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('company_admin', 'supervisor')
    )
  );

-- Policies for support_tickets
CREATE POLICY "Users can view support tickets in same tenant"
  ON support_tickets FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
    OR
    created_by = auth.uid()
  );

CREATE POLICY "Users can create support tickets"
  ON support_tickets FOR INSERT
  TO authenticated
  WITH CHECK (created_by = auth.uid());

-- Policies for feature_flags
CREATE POLICY "SaaS admins can manage feature flags"
  ON feature_flags FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'saas_admin'
    )
  );

CREATE POLICY "All users can view feature flags"
  ON feature_flags FOR SELECT
  TO authenticated
  USING (true);

-- Policies for tenant_features
CREATE POLICY "Users can view tenant features"
  ON tenant_features FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
    OR
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
      AND users.role = 'saas_admin'
    )
  );

-- Policies for vehicles
CREATE POLICY "Users can view vehicles in same tenant"
  ON vehicles FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage vehicles"
  ON vehicles FOR ALL
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('company_admin', 'supervisor')
    )
  );