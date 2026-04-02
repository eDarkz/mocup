import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || '';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_SUPABASE_ANON_KEY || '';

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('Missing Supabase environment variables');
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

export type UserRole = 'saas_admin' | 'company_admin' | 'supervisor' | 'technician' | 'client';

export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string;
          tenant_id: string | null;
          email: string;
          first_name: string;
          last_name: string;
          phone: string | null;
          avatar_url: string | null;
          role: UserRole;
          status: string;
          created_at: string;
          last_login: string | null;
        };
      };
      tenants: {
        Row: {
          id: string;
          name: string;
          slug: string;
          logo_url: string | null;
          contact_email: string;
          phone: string | null;
          subscription_plan_id: string | null;
          status: string;
          created_at: string;
          updated_at: string;
        };
      };
    };
  };
}
