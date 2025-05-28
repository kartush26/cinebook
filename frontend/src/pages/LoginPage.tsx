import { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useMutation } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { Auth } from '@/api/endpoints';
import { useAuthStore } from '@/store/auth';

export function LoginPage() {
  const [email, setEmail] = useState('user@cinebook.test');
  const [password, setPassword] = useState('User@12345');
  const setTokens = useAuthStore(s => s.setTokens);
  const nav = useNavigate(); const loc = useLocation();

  const m = useMutation({
    mutationFn: () => Auth.login(email, password),
    onSuccess: (data) => {
      setTokens({ accessToken: data.access_token, refreshToken: data.refresh_token, user: data.user });
      toast.success(`Welcome back, ${data.user.name}`);
      nav((loc.state as any)?.from ?? '/', { replace: true });
    },
    onError: (err: any) => {
      const message =
        err.response?.data?.error?.message ??
        (err.request && !err.response ? 'Cannot reach API — is Rails running on port 3000?' : 'Login failed');
      console.error('Login error:', err.response?.data ?? err.message);
      toast.error(message);
    }
  });

  return (
    <div className="max-w-md mx-auto px-4 py-16">
      <h1 className="text-2xl font-bold mb-1 text-slate-900">Welcome back</h1>
      <p className="text-slate-500 mb-6 text-sm">Sign in to your CineBook account.</p>
      <form onSubmit={e => { e.preventDefault(); m.mutate(); }} className="space-y-3">
        <label className="block text-sm">
          <span className="text-slate-700 font-medium">Email</span>
          <input className="input mt-1" value={email} onChange={e => setEmail(e.target.value)} type="email" required />
        </label>
        <label className="block text-sm">
          <span className="text-slate-700 font-medium">Password</span>
          <input className="input mt-1" value={password} onChange={e => setPassword(e.target.value)} type="password" required minLength={8} />
        </label>
        <button className="btn-primary w-full" disabled={m.isPending}>{m.isPending ? 'Signing in…' : 'Sign in'}</button>
      </form>
      <p className="text-sm text-slate-500 mt-4">No account? <Link to="/signup" className="text-brand font-medium">Create one</Link></p>
    </div>
  );
}
