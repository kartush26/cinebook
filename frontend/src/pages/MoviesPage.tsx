import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Movies } from '@/api/endpoints';
import { Search, Star } from 'lucide-react';

const LANGS  = ['All', 'English', 'Hindi', 'Japanese', 'Tamil'];
const GENRES = ['All', 'Action', 'Drama', 'Sci-Fi', 'Romance', 'Thriller', 'Anime'];

export function MoviesPage() {
  const [q, setQ] = useState('');
  const [language, setLanguage] = useState('All');
  const [genre, setGenre] = useState('All');

  const { data, isLoading } = useQuery({
    queryKey: ['movies', { q, language, genre }],
    queryFn: () => Movies.list({
      q: q || undefined,
      language: language !== 'All' ? language : undefined,
      genre: genre !== 'All' ? genre : undefined
    })
  });

  return (
    <div className="max-w-7xl mx-auto px-4 py-8">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-6">
        <h1 className="text-2xl md:text-3xl font-bold text-slate-900">Movies</h1>
        <div className="flex flex-wrap gap-2">
          <div className="relative">
            <Search size={16} className="absolute left-3 top-2.5 text-slate-400" />
            <input className="input pl-9 w-64" placeholder="Search movies…" value={q} onChange={e => setQ(e.target.value)} />
          </div>
          <Select value={language} setValue={setLanguage} options={LANGS} />
          <Select value={genre}    setValue={setGenre}    options={GENRES} />
        </div>
      </div>

      {isLoading
        ? <p className="text-slate-500">Loading…</p>
        : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
            {data?.data.map(m => (
              <Link key={m.id} to={`/movies/${m.id}`} className="card overflow-hidden hover:ring-2 hover:ring-brand/40 transition group">
                <div className="aspect-[2/3] bg-slate-100 overflow-hidden">
                  {m.poster_url
                    ? <img src={m.poster_url} alt={m.title} className="w-full h-full object-cover group-hover:scale-105 transition" />
                    : <div className="w-full h-full bg-gradient-to-br from-cyan-100 to-sky-200 flex items-center justify-center">
                        <span className="text-3xl">🎬</span>
                      </div>}
                </div>
                <div className="p-3">
                  <h3 className="font-semibold truncate text-slate-900">{m.title}</h3>
                  <p className="text-xs text-slate-500 mt-1">{m.language} · {m.duration_minutes}m</p>
                </div>
              </Link>
            ))}
          </div>
        )}
    </div>
  );
}

function Select({ value, setValue, options }: { value: string; setValue: (v: string) => void; options: string[] }) {
  return (
    <select value={value} onChange={e => setValue(e.target.value)} className="input w-40">
      {options.map(o => <option key={o} value={o}>{o}</option>)}
    </select>
  );
}
