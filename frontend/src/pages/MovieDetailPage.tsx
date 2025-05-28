import { useMemo, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Movies, Show } from '@/api/endpoints';
import { Clock, Star, MapPin } from 'lucide-react';

export function MovieDetailPage() {
  const { id } = useParams<{ id: string }>();
  const { data: movie } = useQuery({ queryKey: ['movie', id], queryFn: () => Movies.show(id!) });
  const [selectedDate, setSelectedDate] = useState<string>(new Date().toISOString().slice(0, 10));

  const groupedShows = useMemo(() => groupShowsByTheaterAndDate(movie?.shows ?? [], selectedDate), [movie, selectedDate]);
  const days = useMemo(() => buildDays(), []);

  if (!movie) return <div className="max-w-7xl mx-auto px-4 py-12 text-slate-500">Loading…</div>;

  return (
    <div>
      <section className="relative bg-gradient-to-br from-cyan-600 to-sky-700">
        <div className="absolute inset-0 -z-10">
          {movie.banner_url
            ? <img src={movie.banner_url} className="w-full h-full object-cover opacity-20" />
            : null}
          <div className="absolute inset-0 bg-gradient-to-t from-cyan-800/60 to-transparent" />
        </div>
        <div className="max-w-7xl mx-auto px-4 py-12 grid md:grid-cols-[260px,1fr] gap-8 relative z-10">
          <div className="aspect-[2/3] rounded-xl overflow-hidden bg-slate-200 shadow-xl">
            {movie.poster_url
              ? <img src={movie.poster_url} alt={movie.title} className="w-full h-full object-cover" />
              : <div className="w-full h-full bg-gradient-to-br from-cyan-200 to-sky-300 flex items-center justify-center text-5xl">🎬</div>}
          </div>
          <div className="text-white">
            <h1 className="text-3xl md:text-4xl font-extrabold">{movie.title}</h1>
            <div className="flex flex-wrap items-center gap-3 mt-3 text-sm text-cyan-100">
              <span className="flex items-center gap-1 text-amber-300 font-semibold"><Star size={14} /> {movie.imdb_rating}/10</span>
              <span>· {movie.language}</span>
              <span className="flex items-center gap-1"><Clock size={14} /> {movie.duration_minutes} min</span>
              <span>· {movie.rating}</span>
            </div>
            <div className="mt-3 flex flex-wrap gap-2">
              {movie.genres.map(g => <span key={g} className="text-xs px-2 py-1 rounded-full bg-white/20 text-white">{g}</span>)}
            </div>
            <p className="mt-5 text-cyan-50 leading-relaxed max-w-3xl">{movie.synopsis}</p>
            <p className="mt-3 text-sm text-cyan-100">Cast: {movie.cast.join(', ')}</p>
            <p className="text-sm text-cyan-100">Director: {movie.director}</p>
          </div>
        </div>
      </section>

      <section className="max-w-7xl mx-auto px-4 py-10">
        <h2 className="text-xl font-bold mb-4 text-slate-900">Book tickets</h2>

        <div className="flex gap-2 mb-6 overflow-x-auto pb-1">
          {days.map(d => (
            <button key={d.value} onClick={() => setSelectedDate(d.value)}
              className={`px-4 py-2 rounded-lg border text-sm whitespace-nowrap transition ${
                selectedDate === d.value
                  ? 'bg-brand text-white border-brand shadow-sm'
                  : 'bg-white border-slate-200 text-slate-600 hover:border-brand hover:text-brand'
              }`}>
              <div className="font-semibold">{d.label}</div>
              <div className="text-[11px] opacity-70">{d.sub}</div>
            </button>
          ))}
        </div>

        {groupedShows.length === 0
          ? <p className="text-slate-500">No shows available on this date.</p>
          : (
            <div className="space-y-4">
              {groupedShows.map(g => (
                <div key={g.theater.id} className="card p-4">
                  <div className="flex items-center justify-between flex-wrap gap-2 mb-3">
                    <div className="flex items-center gap-2">
                      <MapPin size={16} className="text-brand" />
                      <h3 className="font-semibold text-slate-900">{g.theater.name}</h3>
                      <span className="text-xs text-slate-500">· {g.theater.city}</span>
                    </div>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    {g.shows.map(s => (
                      <Link key={s.id} to={`/shows/${s.id}/seats`}
                        className="px-3 py-2 rounded-md bg-slate-50 border border-slate-200 hover:border-brand hover:bg-cyan-50 hover:text-brand text-sm text-slate-700 transition">
                        {new Date(s.starts_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        <span className="ml-2 text-xs text-slate-400">{s.screen.screen_type.toUpperCase()}</span>
                      </Link>
                    ))}
                  </div>
                </div>
              ))}
            </div>
          )}
      </section>
    </div>
  );
}

function buildDays() {
  return Array.from({ length: 7 }, (_, i) => {
    const d = new Date(); d.setDate(d.getDate() + i);
    return {
      value: d.toISOString().slice(0, 10),
      label: i === 0 ? 'Today' : d.toLocaleDateString([], { weekday: 'short' }),
      sub:   d.toLocaleDateString([], { day: 'numeric', month: 'short' })
    };
  });
}

function groupShowsByTheaterAndDate(shows: Show[], date: string) {
  const filtered = shows.filter(s => s.starts_at.slice(0, 10) === date);
  const byTheater = new Map<string, { theater: Show['theater']; shows: Show[] }>();
  filtered.forEach(s => {
    if (!byTheater.has(s.theater.id)) byTheater.set(s.theater.id, { theater: s.theater, shows: [] });
    byTheater.get(s.theater.id)!.shows.push(s);
  });
  return Array.from(byTheater.values()).map(g => ({
    ...g,
    shows: g.shows.sort((a, b) => a.starts_at.localeCompare(b.starts_at))
  }));
}
