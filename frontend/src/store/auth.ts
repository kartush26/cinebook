import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export type AuthUser = {
  id: string;
  name: string;
  email: string;
  role: 'customer' | 'admin';
};

type AuthState = {
  accessToken:  string | null;
  refreshToken: string | null;
  user:         AuthUser | null;
  setTokens:    (p: { accessToken: string; refreshToken: string; user: AuthUser }) => void;
  clear:        () => void;
};

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      accessToken: null,
      refreshToken: null,
      user: null,
      setTokens: ({ accessToken, refreshToken, user }) => set({ accessToken, refreshToken, user }),
      clear: () => set({ accessToken: null, refreshToken: null, user: null })
    }),
    { name: 'cinebook-auth' }
  )
);
