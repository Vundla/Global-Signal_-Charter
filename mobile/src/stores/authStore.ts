/**
 * Zustand Auth Store
 * Manages authentication state, biometric login, and user sessions
 */

import { create } from 'zustand';

export interface User {
  id: string;
  email: string;
  name: string;
  biometric_enabled: boolean;
}

export interface AuthState {
  user: User | null;
  isLoading: boolean;
  isAuthenticated: boolean;
  accessToken: string | null;
  error: string | null;
  
  // Actions
  setUser: (user: User) => void;
  setAccessToken: (token: string) => void;
  setLoading: (loading: boolean) => void;
  setError: (error: string | null) => void;
  logout: () => void;
  reset: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: false,
  isAuthenticated: false,
  accessToken: null,
  error: null,
  
  setUser: (user) => set({ user, isAuthenticated: !!user }),
  setAccessToken: (accessToken) => set({ accessToken }),
  setLoading: (isLoading) => set({ isLoading }),
  setError: (error) => set({ error }),
  
  logout: () => set({
    user: null,
    isAuthenticated: false,
    accessToken: null,
    error: null,
  }),
  
  reset: () => set({
    user: null,
    isLoading: false,
    isAuthenticated: false,
    accessToken: null,
    error: null,
  }),
}));
