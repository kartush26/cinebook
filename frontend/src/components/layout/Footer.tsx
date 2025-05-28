export function Footer() {
  return (
    <footer className="border-t border-slate-200 mt-12 bg-white">
      <div className="max-w-7xl mx-auto px-4 py-8 text-sm text-slate-500 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
        <p>© {new Date().getFullYear()} CineBook — a production-grade reference build.</p>
        <p className="text-slate-400">React · Rails · PostgreSQL · Redis · Stripe</p>
      </div>
    </footer>
  );
}
