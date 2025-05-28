import { Link } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { Movies, Movie } from '@/api/endpoints';
import { Sparkles, Star, Play } from 'lucide-react';

export function HomePage() {
  const featured = useQuery({ queryKey: ['featured'], queryFn: Movies.featured });
  const showing  = useQuery({ queryKey: ['movies', { showing: true }], queryFn: () => Movies.list({}) });
  const hero = featured.data?.[0];

  return (
    <div>
      {/* Hero */}
      <section className="relative overflow-hidden bg-gradient-to-br from-cyan-600 to-sky-700">
        <div className="absolute inset-0 -z-10">
          {hero?.banner_url
            ? <img src={hero.banner_url} className="w-full h-full object-cover opacity-20" alt="" />
            : null}
          <div className="absolute inset-0 bg-gradient-to-t from-cyan-700/80 to-transparent" />
        </div>
        <div className="max-w-7xl mx-auto px-4 py-20 md:py-28 relative z-10">
          <div className="max-w-2xl">
            <span className="inline-flex items-center gap-2 text-xs uppercase tracking-widest text-cyan-100">
              <Sparkles size={14} /> Now showing
            </span>
            <h1 className="mt-3 text-4xl md:text-6xl font-extrabold leading-tight text-white">
              {hero?.title ?? 'Find your seat. Live the story.'}
            </h1>
            <p className="mt-4 text-cyan-100 text-lg max-w-xl">
              {hero?.synopsis ?? 'Book tickets to the latest blockbusters with a beautiful, real-time seat picker.'}
            </p>
            <div className="mt-6 flex gap-3">
              {hero
                ? <Link to={`/movies/${hero.id}`} className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg font-semibold bg-white text-brand hover:bg-cyan-50 transition shadow-md"><Play size={16}/> Book now</Link>
                : <Link to="/movies" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg font-semibold bg-white text-brand hover:bg-cyan-50 transition shadow-md"><Play size={16}/> Browse movies</Link>}
              <Link to="/movies" className="inline-flex items-center gap-2 px-5 py-2.5 rounded-lg font-semibold bg-white/20 text-white hover:bg-white/30 transition">All movies</Link>
            </div>
          </div>
        </div>
      </section>

      {/* Featured rail */}
      {featured.data && featured.data.length > 0 && (
        <Rail title="This week's picks" items={featured.data} />
      )}

      {/* Now showing */}
      <Rail title="Now showing" items={showing.data?.data ?? []} />
    </div>
  );
}

function Rail({ title, items }: { title: string; items: Movie[] }) {
  return (
    <section className="max-w-7xl mx-auto px-4 py-10">
      <h2 className="text-xl md:text-2xl font-bold mb-4 text-slate-900">{title}</h2>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        {items.map((m) => (
          <Link key={m.id} to={`/movies/${m.id}`} className="group card overflow-hidden hover:ring-2 hover:ring-brand/40 transition">
            <div className="aspect-[2/3] bg-slate-100 overflow-hidden">
              {m.poster_url
                ? <img src={m.poster_url} alt={m.title} className="w-full h-full object-cover group-hover:scale-105 transition" />
                : <div className="w-full h-full bg-gradient-to-br from-cyan-100 to-sky-200 flex items-center justify-center">
                    <span className="text-3xl">🎬</span>
                  </div>}
            </div>
            <div className="p-3">
              <div className="flex items-center justify-between">
                <h3 className="font-semibold truncate text-slate-900">{m.title}</h3>
                <span className="flex items-center gap-1 text-xs text-amber-500 font-medium"><Star size={12} /> {m.imdb_rating}</span>
              </div>
              <p className="text-xs text-slate-500 mt-1">{m.language} · {m.genres.slice(0, 2).join(' · ')}</p>
            </div>
          </Link>
        ))}
      </div>
    </section>
  );
}
