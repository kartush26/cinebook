import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { Bookings } from '@/api/endpoints';
import { Ticket, X, QrCode } from 'lucide-react';

export function BookingsPage() {
  const qc = useQueryClient();
  const { data, isLoading } = useQuery({ queryKey: ['bookings'], queryFn: Bookings.list });

  const cancel = useMutation({
    mutationFn: (id: string) => Bookings.cancel(id),
    onSuccess: () => { toast.success('Booking cancelled'); qc.invalidateQueries({ queryKey: ['bookings'] }); },
    onError:   (err: any) => toast.error(err.response?.data?.error?.message ?? 'Cancellation failed')
  });

  return (
    <div className="max-w-5xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-6 text-slate-900">My Bookings</h1>
      {isLoading && <p className="text-slate-500">Loading…</p>}
      {data?.data.length === 0 && <p className="text-slate-500">No bookings yet. Browse <a className="text-brand font-medium" href="/movies">movies</a>.</p>}
      <div className="space-y-3">
        {data?.data.map(b => (
          <div key={b.id} className="card p-4 flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div className="flex items-start gap-3">
              <Ticket className="text-brand mt-1" size={20} />
              <div>
                <div className="font-semibold text-slate-900">{b.show.movie.title}</div>
                <div className="text-sm text-slate-500">{b.show.theater.name} · {b.show.screen.name}</div>
                <div className="text-sm text-slate-500">{new Date(b.show.starts_at).toLocaleString()}</div>
                <div className="text-xs text-slate-400 mt-1">Ref: {b.reference} · {b.seats.map(s => s.label).join(', ')}</div>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <span className="text-sm px-2 py-1 rounded-full bg-slate-100 text-slate-600 border border-slate-200">{b.status}</span>
              <span className="font-semibold text-slate-900">${b.total_amount}</span>
              {b.status === 'confirmed' && (
                <button className="btn-ghost text-sm"><QrCode size={16}/> Ticket</button>
              )}
              {(b.status === 'confirmed' || b.status === 'pending') && (
                <button onClick={() => cancel.mutate(b.id)} className="btn-ghost text-sm text-red-500"><X size={16}/> Cancel</button>
              )}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
