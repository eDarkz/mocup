/*
  # Create Pest and Chemical Management Tables
  
  1. New Tables
    - `pests` - Catalog of pests
    - `pest_protocols` - Treatment protocols for pests
    - `chemicals` - Chemical products inventory
    - `chemical_batches` - Batch tracking for chemicals
    - `chemical_usage` - Chemical usage log
    - `inventory_movements` - Chemical inventory tracking
    
  2. Security
    - Enable RLS on all tables
    - Tenant-based access control
*/

-- Pests catalog
CREATE TABLE IF NOT EXISTS pests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid REFERENCES tenants(id) ON DELETE CASCADE,
  common_name text NOT NULL,
  scientific_name text,
  category text NOT NULL CHECK (category IN ('insect', 'rodent', 'bird', 'other')),
  icon text,
  description text,
  risk_level text CHECK (risk_level IN ('low', 'medium', 'high', 'critical')),
  is_global boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

-- Pest treatment protocols
CREATE TABLE IF NOT EXISTS pest_protocols (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  pest_id uuid NOT NULL REFERENCES pests(id) ON DELETE CASCADE,
  protocol_name text NOT NULL,
  description text,
  recommended_treatments jsonb DEFAULT '[]',
  dosage_instructions text,
  safety_precautions text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Chemicals inventory
CREATE TABLE IF NOT EXISTS chemicals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  product_name text NOT NULL,
  brand text,
  active_ingredient text,
  concentration text,
  category text NOT NULL CHECK (category IN ('insecticide', 'rodenticide', 'larvicide', 'repellent', 'disinfectant', 'other')),
  unit text NOT NULL DEFAULT 'liter',
  stock_quantity numeric(10,2) DEFAULT 0,
  reorder_level numeric(10,2) DEFAULT 0,
  unit_price numeric(10,2) DEFAULT 0,
  sds_document_url text,
  restrictions jsonb DEFAULT '[]',
  status text DEFAULT 'active' CHECK (status IN ('active', 'discontinued', 'out_of_stock')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Chemical batches
CREATE TABLE IF NOT EXISTS chemical_batches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chemical_id uuid NOT NULL REFERENCES chemicals(id) ON DELETE CASCADE,
  batch_number text NOT NULL,
  manufacture_date date,
  expiry_date date,
  quantity numeric(10,2) NOT NULL,
  supplier text,
  cost_per_unit numeric(10,2),
  received_date date DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now()
);

-- Chemical usage log
CREATE TABLE IF NOT EXISTS chemical_usage (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  fumigation_id uuid NOT NULL REFERENCES fumigations(id) ON DELETE CASCADE,
  chemical_id uuid NOT NULL REFERENCES chemicals(id),
  batch_id uuid REFERENCES chemical_batches(id),
  quantity_used numeric(10,2) NOT NULL,
  application_method text,
  used_at timestamptz DEFAULT now()
);

-- Inventory movements
CREATE TABLE IF NOT EXISTS inventory_movements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  chemical_id uuid NOT NULL REFERENCES chemicals(id) ON DELETE CASCADE,
  movement_type text NOT NULL CHECK (movement_type IN ('in', 'out', 'adjustment', 'return')),
  quantity numeric(10,2) NOT NULL,
  reference_id uuid,
  reference_type text,
  notes text,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE pests ENABLE ROW LEVEL SECURITY;
ALTER TABLE pest_protocols ENABLE ROW LEVEL SECURITY;
ALTER TABLE chemicals ENABLE ROW LEVEL SECURITY;
ALTER TABLE chemical_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE chemical_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_movements ENABLE ROW LEVEL SECURITY;

-- Policies for pests
CREATE POLICY "Users can view global and tenant pests"
  ON pests FOR SELECT
  TO authenticated
  USING (
    is_global = true
    OR
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

-- Policies for pest_protocols
CREATE POLICY "Users can view protocols in same tenant"
  ON pest_protocols FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

-- Policies for chemicals
CREATE POLICY "Users can view chemicals in same tenant"
  ON chemicals FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );

CREATE POLICY "Admins can manage chemicals"
  ON chemicals FOR ALL
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('company_admin', 'supervisor')
    )
  );

-- Policies for chemical_batches
CREATE POLICY "Users can view batches in same tenant"
  ON chemical_batches FOR SELECT
  TO authenticated
  USING (
    chemical_id IN (
      SELECT id FROM chemicals 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
  );

-- Policies for chemical_usage
CREATE POLICY "Users can view chemical usage in same tenant"
  ON chemical_usage FOR SELECT
  TO authenticated
  USING (
    fumigation_id IN (
      SELECT id FROM fumigations 
      WHERE location_id IN (
        SELECT id FROM locations 
        WHERE tenant_id IN (
          SELECT tenant_id FROM users WHERE users.id = auth.uid()
        )
      )
    )
  );

-- Policies for inventory_movements
CREATE POLICY "Users can view inventory movements in same tenant"
  ON inventory_movements FOR SELECT
  TO authenticated
  USING (
    tenant_id IN (
      SELECT tenant_id FROM users WHERE users.id = auth.uid()
    )
  );