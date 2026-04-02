/*
  # Create Financial and Reporting Tables
  
  1. New Tables
    - `invoices` - Customer invoices
    - `invoice_items` - Line items for invoices
    - `payments` - Payment records
    - `reports` - Fumigation reports
    - `certificates` - Compliance certificates
    
  2. Security
    - Enable RLS on all tables
    - Tenant-based access control
*/

-- Invoices
CREATE TABLE IF NOT EXISTS invoices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  invoice_number text UNIQUE NOT NULL,
  issue_date date NOT NULL DEFAULT CURRENT_DATE,
  due_date date NOT NULL,
  subtotal numeric(10,2) DEFAULT 0,
  tax_amount numeric(10,2) DEFAULT 0,
  total_amount numeric(10,2) NOT NULL DEFAULT 0,
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'sent', 'paid', 'overdue', 'cancelled')),
  payment_terms text,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Invoice items
CREATE TABLE IF NOT EXISTS invoice_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  service_order_id uuid REFERENCES service_orders(id),
  description text NOT NULL,
  quantity numeric(10,2) NOT NULL DEFAULT 1,
  unit_price numeric(10,2) NOT NULL DEFAULT 0,
  amount numeric(10,2) NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now()
);

-- Payments
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_id uuid NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  payment_date date NOT NULL DEFAULT CURRENT_DATE,
  amount numeric(10,2) NOT NULL,
  payment_method text NOT NULL CHECK (payment_method IN ('cash', 'check', 'credit_card', 'debit_card', 'transfer', 'other')),
  reference_number text,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Fumigation reports
CREATE TABLE IF NOT EXISTS reports (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fumigation_id uuid NOT NULL REFERENCES fumigations(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES customers(id),
  location_id uuid NOT NULL REFERENCES locations(id),
  technician_id uuid NOT NULL REFERENCES users(id),
  report_number text UNIQUE NOT NULL,
  report_date date NOT NULL DEFAULT CURRENT_DATE,
  report_type text DEFAULT 'standard' CHECK (report_type IN ('standard', 'inspection', 'emergency', 'follow_up')),
  findings jsonb DEFAULT '[]',
  recommendations text,
  pdf_url text,
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'pending_signature', 'signed', 'approved')),
  signed_at timestamptz,
  signed_by text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Compliance certificates
CREATE TABLE IF NOT EXISTS certificates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  report_id uuid REFERENCES reports(id),
  certificate_number text UNIQUE NOT NULL,
  certificate_type text NOT NULL CHECK (certificate_type IN ('cofepris', 'health', 'sanitary', 'compliance', 'other')),
  issue_date date NOT NULL DEFAULT CURRENT_DATE,
  expiry_date date,
  pdf_url text,
  issued_by uuid REFERENCES users(id),
  status text DEFAULT 'active' CHECK (status IN ('active', 'expired', 'revoked')),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoice_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE certificates ENABLE ROW LEVEL SECURITY;

-- Policies for invoices
CREATE POLICY "Users can view invoices in same tenant"
  ON invoices FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage invoices"
  ON invoices FOR ALL
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('company_admin', 'supervisor')
    )
  );

-- Policies for invoice_items
CREATE POLICY "Users can view invoice items in same tenant"
  ON invoice_items FOR SELECT
  TO authenticated
  USING (
    invoice_id IN (
      SELECT id FROM invoices 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
  );

-- Policies for payments
CREATE POLICY "Users can view payments in same tenant"
  ON payments FOR SELECT
  TO authenticated
  USING (
    invoice_id IN (
      SELECT id FROM invoices 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
  );

-- Policies for reports
CREATE POLICY "Users can view reports in same tenant"
  ON reports FOR SELECT
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

CREATE POLICY "Technicians can create reports"
  ON reports FOR INSERT
  TO authenticated
  WITH CHECK (technician_id = auth.uid());

CREATE POLICY "Technicians can update own reports"
  ON reports FOR UPDATE
  TO authenticated
  USING (technician_id = auth.uid())
  WITH CHECK (technician_id = auth.uid());

-- Policies for certificates
CREATE POLICY "Users can view certificates in same tenant"
  ON certificates FOR SELECT
  TO authenticated
  USING (
    location_id IN (
      SELECT id FROM locations 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
  );