/*
  # Seed Demo Data for FumiControl SaaS
  
  1. Demo Data
    - Create demo subscription plans
    - Create demo tenants
    - Create demo users (one for each role)
    - Create demo customers
    - Create demo locations
    
  2. Notes
    - All passwords are 'demo' for testing
    - User IDs are generated for demo accounts
*/

-- Insert subscription plans
INSERT INTO subscription_plans (id, name, description, price_monthly, price_annual, max_locations, max_users, max_technicians, features, is_active)
VALUES
  (gen_random_uuid(), 'Básico', 'Plan ideal para pequeñas empresas', 29.99, 299.99, 10, 3, 2, '{"gps_tracking": false, "api_access": false, "white_label": false}'::jsonb, true),
  (gen_random_uuid(), 'Pro', 'Plan profesional con más funciones', 79.99, 799.99, 50, 10, 10, '{"gps_tracking": true, "api_access": false, "white_label": false}'::jsonb, true),
  (gen_random_uuid(), 'Enterprise', 'Plan empresarial completo', 199.99, 1999.99, null, null, null, '{"gps_tracking": true, "api_access": true, "white_label": true}'::jsonb, true)
ON CONFLICT DO NOTHING;

-- Insert demo tenant
INSERT INTO tenants (id, name, slug, contact_email, phone, status)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Fumigaciones López S.A.', 'fumigaciones-lopez', 'contacto@fumigacioneslopez.com', '+52 81 1234 5678', 'active')
ON CONFLICT DO NOTHING;

-- Insert demo users (these will be created manually in Supabase Auth)
-- Note: In a real app, these would be created via Supabase Auth API
INSERT INTO users (id, tenant_id, email, first_name, last_name, phone, role, status)
VALUES
  ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', NULL, 'saas@demo.com', 'Super', 'Admin', '+52 81 1111 1111', 'saas_admin', 'active'),
  ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'empresa@demo.com', 'Juan', 'López', '+52 81 2222 2222', 'company_admin', 'active'),
  ('d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'super@demo.com', 'María', 'González', '+52 81 3333 3333', 'supervisor', 'active'),
  ('e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'tecnico@demo.com', 'Carlos', 'Ramírez', '+52 81 4444 4444', 'technician', 'active'),
  ('f0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'cliente@demo.com', 'Roberto', 'Martínez', '+52 81 5555 5555', 'client', 'active')
ON CONFLICT DO NOTHING;

-- Insert demo customers
INSERT INTO customers (id, tenant_id, name, type, contact_person, email, phone, address, city, state, postal_code, status)
VALUES
  (gen_random_uuid(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Hotel Marriott Centro', 'hotel', 'Roberto Martínez', 'roberto@marriott.com', '+52 81 6666 6666', 'Av. Constitución 444 Pte', 'Monterrey', 'Nuevo León', '64000', 'active'),
  (gen_random_uuid(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Hotel Hilton', 'hotel', 'Ana García', 'ana@hilton.com', '+52 81 7777 7777', 'Av. Fundidora 650', 'Monterrey', 'Nuevo León', '64010', 'active'),
  (gen_random_uuid(), 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Restaurante La Parilla', 'commercial', 'Jorge Sánchez', 'jorge@laparilla.com', '+52 81 8888 8888', 'Av. Hidalgo 234', 'Monterrey', 'Nuevo León', '64000', 'active')
ON CONFLICT DO NOTHING;

-- Insert demo locations
DO $$
DECLARE
  customer1_id uuid;
  customer2_id uuid;
  customer3_id uuid;
BEGIN
  SELECT id INTO customer1_id FROM customers WHERE name = 'Hotel Marriott Centro' LIMIT 1;
  SELECT id INTO customer2_id FROM customers WHERE name = 'Hotel Hilton' LIMIT 1;
  SELECT id INTO customer3_id FROM customers WHERE name = 'Restaurante La Parilla' LIMIT 1;

  IF customer1_id IS NOT NULL THEN
    INSERT INTO locations (tenant_id, customer_id, name, type, address, city, state, postal_code, total_area_sqm, floors, status)
    VALUES
      ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', customer1_id, 'Hotel Marriott Centro', 'hotel', 'Av. Constitución 444 Pte', 'Monterrey', 'Nuevo León', '64000', 5000.00, 10, 'active')
    ON CONFLICT DO NOTHING;
  END IF;

  IF customer2_id IS NOT NULL THEN
    INSERT INTO locations (tenant_id, customer_id, name, type, address, city, state, postal_code, total_area_sqm, floors, status)
    VALUES
      ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', customer2_id, 'Hotel Hilton', 'hotel', 'Av. Fundidora 650', 'Monterrey', 'Nuevo León', '64010', 4500.00, 8, 'active')
    ON CONFLICT DO NOTHING;
  END IF;

  IF customer3_id IS NOT NULL THEN
    INSERT INTO locations (tenant_id, customer_id, name, type, address, city, state, postal_code, total_area_sqm, floors, status)
    VALUES
      ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', customer3_id, 'Restaurante La Parilla', 'commercial', 'Av. Hidalgo 234', 'Monterrey', 'Nuevo León', '64000', 300.00, 1, 'active')
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- Insert demo pests (global)
INSERT INTO pests (id, tenant_id, common_name, scientific_name, category, icon, risk_level, is_global)
VALUES
  (gen_random_uuid(), NULL, 'Cucarachas', 'Blattodea', 'insect', '🪳', 'high', true),
  (gen_random_uuid(), NULL, 'Roedores', 'Rodentia', 'rodent', '🐀', 'critical', true),
  (gen_random_uuid(), NULL, 'Hormigas', 'Formicidae', 'insect', '🐜', 'medium', true),
  (gen_random_uuid(), NULL, 'Mosquitos', 'Culicidae', 'insect', '🦟', 'high', true),
  (gen_random_uuid(), NULL, 'Arañas', 'Araneae', 'insect', '🕷️', 'low', true),
  (gen_random_uuid(), NULL, 'Termitas', 'Isoptera', 'insect', '🪲', 'critical', true)
ON CONFLICT DO NOTHING;

-- Insert demo chemicals
INSERT INTO chemicals (tenant_id, product_name, brand, active_ingredient, concentration, category, unit, stock_quantity, reorder_level, unit_price, status)
VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Insecticida Profesional', 'Bayer', 'Cipermetrina', '25%', 'insecticide', 'liter', 50.00, 10.00, 45.50, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Gel Anti-Cucarachas', 'BASF', 'Fipronil', '0.05%', 'insecticide', 'tube', 30.00, 5.00, 28.00, 'active'),
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Raticida en Bloque', 'Syngenta', 'Bromadiolona', '0.005%', 'rodenticide', 'kilogram', 25.00, 5.00, 120.00, 'active')
ON CONFLICT DO NOTHING;