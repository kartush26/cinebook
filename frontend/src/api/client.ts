import axios, { AxiosError, AxiosInstance } from 'axios';
import { useAuthStore } from '@/store/auth';

// Empty VITE_API_URL in dev → relative /api/* hits Vite proxy → Rails (no CORS).
const API_URL = import.meta.env.VITE_API_URL?.trim() ?? '';

export const api: AxiosInstance = axios.create({
  baseURL: API_URL,
  headers: { 'Content-Type': 'application/json' }
});

api.interceptors.request.use((config) => {
  const token = useAuthStore.getState().accessToken;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

let refreshInFlight: Promise<string | null> | null = null;

api.interceptors.response.use(
  (r) => r,
  async (err: AxiosError<{ error?: { code?: string } }>) => {
    const original = err.config as any;
    if (err.response?.status === 401 && !original?._retried && !original?.url?.includes('/auth/')) {
      original._retried = true;
      refreshInFlight ||= refreshTokens();
      const next = await refreshInFlight;
      refreshInFlight = null;
      if (next) {
        original.headers.Authorization = `Bearer ${next}`;
        return api(original);
      }
    }
    return Promise.reject(err);
  }
);

async function refreshTokens(): Promise<string | null> {
  const { refreshToken, setTokens, clear } = useAuthStore.getState();
  if (!refreshToken) return null;
  try {
    const { data } = await axios.post(`${API_URL}/api/v1/auth/refresh`, { refresh_token: refreshToken });
    setTokens({
      accessToken:  data.data.access_token,
      refreshToken: data.data.refresh_token,
      user:         data.data.user
    });
    return data.data.access_token;
  } catch {
    clear();
    return null;
  }
}

export type ApiEnvelope<T> = { data: T; meta?: { current_page: number; total_pages: number; total_count: number; per_page: number } };
export type ApiError       = { error: { code: string; message: string; details?: unknown } };
