import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { api } from '@/api/client';
import { Admin } from '@/api/admin';

export function AdminMovies() {
  const qc = useQueryClient();
  const { data } = useQuery({ queryKey: ['admin-movies'], queryFn: Admin.movies.list });
  const [form, setForm] = useState({
    title: '', language: 'English', duration_minutes: 120, rating: 'UA',
    release_date: new Date().toISOString().slice(0, 10),
    synopsis: '', director: '', genres: 'Drama', cast: '', imdb_rating: 7.5,
    status: 'now_showing'
  });
  const [poster, setPoster] = useState<File | null>(null);
  const [banner, setBanner] = useState<File | null>(null);

  const create = useMutation({
    mutationFn: () => {
      const fd = new FormData();
      const movie = {
        ...form,
        genres: form.genres.split(',').map(s => s.trim()),
        cast:   form.cast.split(',').map(s => s.trim()).filter(Boolean)
      };
      Object.entries(movie).forEach(([k, v]) => {
        if (Array.isArray(v)) v.forEach(item => fd.append(`movie[${k}][]`, item));
        else fd.append(`movie[${k}]`, String(v));
      });
      if (poster) fd.append('poster', poster);
      if (banner) fd.append('banner', banner);
      return api.post('/api/v1/admin/movies', fd, {
        headers: { 'Content-Type': 'multipart/form-data' }
      }).then(r => r.data.data);
    },
    onSuccess: () => {
      toast.success('Movie created');
      qc.invalidateQueries({ queryKey: ['admin-movies'] });
      setPoster(null);
      setBanner(null);
    },
    onError: (e: any) => toast.error(e.response?.data?.error?.message ?? 'Failed')
  });

  const remove = useMutation({
    mutationFn: (id: string) => Admin.movies.remove(id),
    onSuccess: () => { toast.success('Archived'); qc.invalidateQueries({ queryKey: ['admin-movies'] }); }
  });

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-6 text-slate-900">Movies</h1>
      <div className="grid md:grid-cols-2 gap-6">
        <section className="card p-5">
          <h2 className="font-semibold mb-3 text-slate-900">Create movie</h2>
          <form onSubmit={e => { e.preventDefault(); create.mutate(); }} className="space-y-2 text-sm">
            <input className="input" placeholder="Title" value={form.title} onChange={e => setForm({ ...form, title: e.target.value })} required />
            <textarea className="input" placeholder="Synopsis" rows={3} value={form.synopsis} onChange={e => setForm({ ...form, synopsis: e.target.value })} />
            <div className="grid grid-cols-2 gap-2">
              <input className="input" placeholder="Language" value={form.language} onChange={e => setForm({ ...form, language: e.target.value })} />
              <input className="input" placeholder="Director" value={form.director} onChange={e => setForm({ ...form, director: e.target.value })} />
              <input className="input" type="number" min={30} placeholder="Duration (min)" value={form.duration_minutes} onChange={e => setForm({ ...form, duration_minutes: +e.target.value })} />
              <select className="input" value={form.rating} onChange={e => setForm({ ...form, rating: e.target.value })}>
                <option>U</option><option>UA</option><option>A</option>
              </select>
              <input className="input" type="date" value={form.release_date} onChange={e => setForm({ ...form, release_date: e.target.value })} />
              <input className="input" type="number" step="0.1" min="0" max="10" placeholder="IMDB" value={form.imdb_rating} onChange={e => setForm({ ...form, imdb_rating: +e.target.value })} />
            </div>
            <input className="input" placeholder="Genres (comma separated)" value={form.genres} onChange={e => setForm({ ...form, genres: e.target.value })} />
            <input className="input" placeholder="Cast (comma separated)" value={form.cast} onChange={e => setForm({ ...form, cast: e.target.value })} />

            <div className="grid grid-cols-2 gap-2 pt-1">
              <label className="block">
                <span className="text-xs text-slate-500 mb-1 block">Poster image</span>
                <input
                  type="file" accept="image/*"
                  onChange={e => setPoster(e.target.files?.[0] ?? null)}
                  className="block w-full text-xs text-slate-500
                    file:mr-2 file:py-1.5 file:px-3 file:rounded-md file:border-0
                    file:text-xs file:font-medium file:bg-cyan-50 file:text-brand
                    hover:file:bg-cyan-100 cursor-pointer"
                />
                {poster && <p className="text-xs text-brand mt-1 truncate">{poster.name}</p>}
              </label>
              <label className="block">
                <span className="text-xs text-slate-500 mb-1 block">Banner image</span>
                <input
                  type="file" accept="image/*"
                  onChange={e => setBanner(e.target.files?.[0] ?? null)}
                  className="block w-full text-xs text-slate-500
                    file:mr-2 file:py-1.5 file:px-3 file:rounded-md file:border-0
                    file:text-xs file:font-medium file:bg-cyan-50 file:text-brand
                    hover:file:bg-cyan-100 cursor-pointer"
                />
                {banner && <p className="text-xs text-brand mt-1 truncate">{banner.name}</p>}
              </label>
            </div>

            <button className="btn-primary w-full mt-2" disabled={create.isPending}>
              {create.isPending ? 'Creating…' : 'Create movie'}
            </button>
          </form>
        </section>

        <section className="card p-5">
          <h2 className="font-semibold mb-3 text-slate-900">All movies</h2>
          <div className="space-y-2 max-h-[560px] overflow-auto">
            {data?.data.map(m => (
              <div key={m.id} className="flex items-center justify-between border border-slate-200 rounded-md p-2 gap-3 hover:bg-slate-50 transition">
                {m.poster_url && (
                  <img src={m.poster_url} alt={m.title} className="w-8 h-12 object-cover rounded" />
                )}
                <div className="flex-1 min-w-0">
                  <div className="font-medium truncate text-slate-900">{m.title}</div>
                  <div className="text-xs text-slate-500">{m.language} · {m.status}</div>
                </div>
                <button onClick={() => remove.mutate(m.id)} className="btn-ghost text-xs text-red-500 shrink-0">Archive</button>
              </div>
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}
