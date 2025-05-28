import { useQuery } from '@tanstack/react-query';
import { Admin } from '@/api/admin';

export function AdminShows() {
  const { data } = useQuery({ queryKey: ['admin-shows'], queryFn: Admin.shows.list });
  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-6 text-slate-900">Shows</h1>
      <div className="card overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-slate-50 text-left text-slate-500 border-b border-slate-200">
            <tr>
              <th className="px-4 py-3">Movie</th>
              <th className="px-4 py-3">Theater</th>
              <th className="px-4 py-3">Screen</th>
              <th className="px-4 py-3">Starts</th>
              <th className="px-4 py-3">Status</th>
            </tr>
          </thead>
          <tbody>
            {data?.data.map(s => (
              <tr key={s.id} className="border-t border-slate-100 hover:bg-slate-50 transition">
                <td className="px-4 py-2.5 font-medium text-slate-900">{s.movie.title}</td>
                <td className="px-4 py-2.5 text-slate-600">{s.theater.name}</td>
                <td className="px-4 py-2.5 text-slate-600">{s.screen.name}</td>
                <td className="px-4 py-2.5 text-slate-600">{new Date(s.starts_at).toLocaleString()}</td>
                <td className="px-4 py-2.5">
                  <span className="px-2 py-0.5 rounded-full text-xs bg-cyan-50 text-brand border border-cyan-200">{s.status}</span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
