import { Link, NavLink, useNavigate } from 'react-router-dom';
import { Film, LogOut, ShieldCheck, User } from 'lucide-react';
import { useAuthStore } from '@/store/auth';
import { Auth } from '@/api/endpoints';

export function Navbar() {
  const { user, refreshToken, clear } = useAuthStore();
  const nav = useNavigate();

  const onLogout = async () => {
    try { if (refreshToken) await Auth.logout(refreshToken); } catch {}
    clear(); nav('/');
  };

  const link = ({ isActive }: { isActive: boolean }) =>
    `px-3 py-1.5 rounded-md text-sm font-medium transition ${isActive ? 'text-brand bg-cyan-50' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-100'}`;

  return (
    <header className="sticky top-0 z-30 backdrop-blur-xl bg-white/90 border-b border-slate-200 shadow-sm">
      <div className="max-w-7xl mx-auto flex items-center justify-between px-4 h-16">
        <Link to="/" className="flex items-center gap-2">
          <Film className="text-brand" size={22} />
          <span className="text-lg font-extrabold tracking-tight text-slate-900">Cine<span className="text-brand">Book</span></span>
        </Link>

        <nav className="hidden md:flex items-center gap-1">
          <NavLink to="/movies" className={link}>Movies</NavLink>
          {user && <NavLink to="/bookings" className={link}>My Bookings</NavLink>}
          {user?.role === 'admin' && <NavLink to="/admin" className={link}>Admin</NavLink>}
        </nav>

        <div className="flex items-center gap-2">
          {!user ? (
            <>
              <Link to="/login" className="btn-ghost text-sm">Login</Link>
              <Link to="/signup" className="btn-primary text-sm">Sign up</Link>
            </>
          ) : (
            <div className="flex items-center gap-2">
              <span className="text-sm text-slate-700 hidden sm:flex items-center gap-1.5">
                {user.role === 'admin' ? <ShieldCheck size={16} className="text-brand" /> : <User size={16} />}
                {user.name}
              </span>
              <button onClick={onLogout} className="btn-ghost text-sm" title="Logout">
                <LogOut size={16} />
              </button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
