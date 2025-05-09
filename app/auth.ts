import { create } from 'zustand';
import { supabase } from '@/lib/supabase';

interface AuthState {
  isAuthenticated: boolean;
  role: string | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
}

export const useAuth = create<AuthState>((set) => ({
  isAuthenticated: false,
  role: null,
  login: async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) {
      return false;
    }

    // First try to get the user data
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('role')
      .ilike('email', email)
      .single();

    if (userError || !userData) {
      await supabase.auth.signOut();
      return false;
    }

    // Check if user is an admin (case insensitive)
    if (!userData.role || userData.role.toLowerCase() !== 'admin') {
      await supabase.auth.signOut();
      return false;
    }

    set({
      isAuthenticated: true,
      role: userData.role,
    });

    return true;
  },
  logout: async () => {
    await supabase.auth.signOut();
    set({
      isAuthenticated: false,
      role: null,
    });
  }
}));