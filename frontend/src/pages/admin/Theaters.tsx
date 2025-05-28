import { useQuery } from '@tanstack/react-query';
import { Admin } from '@/api/admin';

export function AdminTheaters() {
  const { data } = useQuery({ queryKey: ['admin-theaters'], queryFn: Admin.theaters.list });
  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-6 text-slate-900">Theaters</h1>
      <div className="grid md:grid-cols-2 gap-3">
        {data?.data.map(t => (
          <div key={t.id} className="card p-4">
            <h3 className="font-semibold text-slate-900">{t.name}</h3>
            <p className="text-sm text-slate-500">{t.address} · {t.city}</p>
          </div>
        ))}
      </div>
    </div>
  );
}
