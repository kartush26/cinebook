import { useForm } from 'react-hook-form';
import { useMutation } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { Link, useNavigate } from 'react-router-dom';
import { Auth } from '@/api/endpoints';
import { useAuthStore } from '@/store/auth';

type Form = { name: string; email: string; password: string };

export function SignupPage() {
  const { register, handleSubmit, formState: { errors } } = useForm<Form>();
  const setTokens = useAuthStore(s => s.setTokens);
  const nav = useNavigate();

  const m = useMutation({
    mutationFn: (data: Form) => Auth.signup(data),
    onSuccess: (data) => {
      setTokens({ accessToken: data.access_token, refreshToken: data.refresh_token, user: data.user });
      toast.success('Account created');
      nav('/');
    },
    onError: (err: any) => toast.error(err.response?.data?.error?.message ?? 'Signup failed')
  });

  return (
    <div className="max-w-md mx-auto px-4 py-16">
      <h1 className="text-2xl font-bold mb-1 text-slate-900">Create your account</h1>
      <p className="text-slate-500 mb-6 text-sm">It takes less than a minute.</p>
      <form onSubmit={handleSubmit(d => m.mutate(d))} className="space-y-3">
        <label className="block text-sm">
          <span className="text-slate-700 font-medium">Name</span>
          <input className="input mt-1" {...register('name', { required: true, maxLength: 80 })} />
          {errors.name && <p className="text-red-500 text-xs mt-1">Name is required</p>}
        </label>
        <label className="block text-sm">
          <span className="text-slate-700 font-medium">Email</span>
          <input className="input mt-1" type="email" {...register('email', { required: true })} />
        </label>
        <label className="block text-sm">
          <span className="text-slate-700 font-medium">Password</span>
          <input className="input mt-1" type="password" {...register('password', { required: true, minLength: 8 })} />
          {errors.password && <p className="text-red-500 text-xs mt-1">Min 8 characters</p>}
        </label>
        <button className="btn-primary w-full" disabled={m.isPending}>{m.isPending ? 'Creating…' : 'Create account'}</button>
      </form>
      <p className="text-sm text-slate-500 mt-4">Already have one? <Link to="/login" className="text-brand font-medium">Sign in</Link></p>
    </div>
  );
}
