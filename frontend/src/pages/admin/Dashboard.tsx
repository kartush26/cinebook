import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Admin } from '@/api/admin';
import { DollarSign, Users, Film, Building2, Ticket, Activity } from 'lucide-react';

export function AdminDashboard() {
  const { data: o } = useQuery({ queryKey: ['admin-overview'], queryFn: Admin.overview });
  const { data: r } = useQuery({ queryKey: ['admin-revenue'],  queryFn: () => Admin.revenue() });

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <header className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-slate-900">Admin Dashboard</h1>
          <p className="text-slate-500 text-sm">Operational overview of CineBook</p>
        </div>
        <div className="flex gap-2">
          <Link to="/admin/movies"   className="btn-ghost">Movies</Link>
          <Link to="/admin/theaters" className="btn-ghost">Theaters</Link>
          <Link to="/admin/shows"    className="btn-primary">Shows</Link>
        </div>
      </header>

      <section className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
        <Stat icon={DollarSign} label="Revenue (all time)" value={`$${(o?.total_revenue ?? 0).toFixed(2)}`} sub={`$${(o?.revenue_last_30 ?? 0).toFixed(2)} last 30d`} />
        <Stat icon={Ticket}     label="Bookings (all)" value={o?.total_bookings ?? '–'} sub={`${o?.bookings_today ?? 0} today`} />
        <Stat icon={Users}      label="Total users"    value={o?.total_users ?? '–'} sub={`${o?.active_users ?? 0} active`} />
        <Stat icon={Activity}   label="Active capacity" value={`${o?.total_movies_showing ?? 0} movies`} sub={`${o?.total_theaters ?? 0} theaters`} />
      </section>

      <section className="card p-5">
        <h2 className="font-semibold mb-3 flex items-center gap-2 text-slate-900"><DollarSign size={16} className="text-brand"/> Revenue (last 30 days)</h2>
        <RevenueChart data={r ?? []} />
      </section>
    </div>
  );
}

function Stat({ icon: Icon, label, value, sub }: { icon: any; label: string; value: string | number; sub?: string }) {
  return (
    <div className="card p-4">
      <div className="flex items-center justify-between text-slate-500 text-sm">
        <span>{label}</span><Icon size={16} className="text-brand" />
      </div>
      <div className="text-2xl font-extrabold mt-1 text-slate-900">{value}</div>
      {sub && <div className="text-xs text-slate-400">{sub}</div>}
    </div>
  );
}

function RevenueChart({ data }: { data: { day: string; revenue: number; bookings: number }[] }) {
  const max = Math.max(1, ...data.map(d => d.revenue));
  if (data.length === 0) return <p className="text-sm text-slate-400">No revenue yet.</p>;
  return (
    <div className="flex items-end gap-1 h-40">
      {data.map(d => (
        <div key={d.day} className="flex-1 flex flex-col items-center gap-1" title={`${d.day}: $${d.revenue.toFixed(2)} (${d.bookings})`}>
          <div className="w-full bg-brand/60 hover:bg-brand rounded-sm transition" style={{ height: `${(d.revenue / max) * 100}%` }} />
          <span className="text-[10px] text-slate-400 truncate">{d.day.slice(5)}</span>
        </div>
      ))}
    </div>
  );
}
