import { create } from 'zustand';
import { supabase } from '@/lib/supabase';
import { useEffect } from 'react';

interface AuthState {
  isAuthenticated: boolean;
  role: string | null;
  isLoading: boolean;
  user?: any;
  initializeAuth: () => Promise<void>;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
}

export const useAuth = create<AuthState>((set) => ({
  isAuthenticated: false,
  role: null,
  isLoading: true,
  initializeAuth: async () => {
    set({ isLoading: true });
    const { data: { session } } = await supabase.auth.getSession();

    if (session?.user) {
      const { data: userData } = await supabase
        .from('users')
        .select('*')
        .ilike('email', session.user.email!)
        .single();

      if (userData?.role?.toLowerCase() === 'admin') {
        set({
          isAuthenticated: true,
          role: userData.role,
          user: userData,
          isLoading: false
        });
        return;
      }
    }

    set({ isLoading: false });
  },
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