/*
  # Create Monitoring Station Tables
  
  1. New Tables
    - `stations` - Monitoring equipment/stations (bait stations, traps, etc.)
    - `station_readings` - Inspection readings from stations
    - `station_schedules` - Maintenance schedules for stations
    
  2. Security
    - Enable RLS on all tables
    - Tenant-based access control
*/

-- Monitoring stations
CREATE TABLE IF NOT EXISTS stations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
  station_code text NOT NULL,
  station_type text NOT NULL CHECK (station_type IN ('baiter', 'light_trap', 'adhesive_trap', 'mechanical_trap', 'monitoring_point')),
  area text,
  coordinates point,
  installation_date date DEFAULT CURRENT_DATE,
  last_inspection_date date,
  next_inspection_date date,
  status text DEFAULT 'active' CHECK (status IN ('active', 'needs_review', 'alert', 'inactive')),
  qr_code text UNIQUE,
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Station readings/inspections
CREATE TABLE IF NOT EXISTS station_readings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  station_id uuid NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  technician_id uuid NOT NULL REFERENCES users(id),
  reading_date date NOT NULL DEFAULT CURRENT_DATE,
  pest_count integer DEFAULT 0,
  pest_types jsonb DEFAULT '[]',
  bait_consumption_percent integer DEFAULT 0,
  condition text CHECK (condition IN ('good', 'needs_cleaning', 'needs_replacement', 'damaged')),
  action_taken text,
  photos jsonb DEFAULT '[]',
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Station maintenance schedules
CREATE TABLE IF NOT EXISTS station_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  station_id uuid NOT NULL REFERENCES stations(id) ON DELETE CASCADE,
  review_frequency_days integer NOT NULL DEFAULT 30,
  assigned_technician_id uuid REFERENCES users(id),
  last_review_date date,
  next_review_date date NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE stations ENABLE ROW LEVEL SECURITY;
ALTER TABLE station_readings ENABLE ROW LEVEL SECURITY;
ALTER TABLE station_schedules ENABLE ROW LEVEL SECURITY;

-- Policies for stations
CREATE POLICY "Users can view stations in same tenant"
  ON stations FOR SELECT
  TO authenticated
  USING (
    location_id IN (
      SELECT id FROM locations 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users WHERE users.id = auth.uid()
      )
    )
  );

CREATE POLICY "Admins and technicians can manage stations"
  ON stations FOR ALL
  TO authenticated
  USING (
    location_id IN (
      SELECT id FROM locations 
      WHERE tenant_id IN (
        SELECT tenant_id FROM users 
        WHERE users.id = auth.uid() 
        AND users.role IN ('company_admin', 'supervisor', 'technician')
      )
    )
  );

-- Policies for station_readings
CREATE POLICY "Users can view station readings in same tenant"
  ON station_readings FOR SELECT
  TO authenticated
  USING (
    station_id IN (
      SELECT id FROM stations 
      WHERE location_id IN (
        SELECT id FROM locations 
        WHERE tenant_id IN (
          SELECT tenant_id FROM users WHERE users.id = auth.uid()
        )
      )
    )
  );

CREATE POLICY "Technicians can create station readings"
  ON station_readings FOR INSERT
  TO authenticated
  WITH CHECK (technician_id = auth.uid());

CREATE POLICY "Technicians can update own readings"
  ON station_readings FOR UPDATE
  TO authenticated
  USING (technician_id = auth.uid())
  WITH CHECK (technician_id = auth.uid());

-- Policies for station_schedules
CREATE POLICY "Users can view station schedules in same tenant"
  ON station_schedules FOR SELECT
  TO authenticated
  USING (
    station_id IN (
      SELECT id FROM stations 
      WHERE location_id IN (
        SELECT id FROM locations 
        WHERE tenant_id IN (
          SELECT tenant_id FROM users WHERE users.id = auth.uid()
        )
      )
    )
  );