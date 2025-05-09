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

    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('role')
      .eq('id', data.user.id)
      .single();

    if (userError || userData?.role !== 'admin') {
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