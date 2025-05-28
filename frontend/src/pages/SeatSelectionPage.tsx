import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery, useMutation } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { Bookings, Seat, Shows } from '@/api/endpoints';
import { SeatMap } from '@/components/seats/SeatMap';
import { useChannel } from '@/hooks/useActionCable';

type RealtimeEvent =
  | { event: 'seat_locked';   seat_ids: string[]; user_id?: string }
  | { event: 'seat_released'; seat_ids: string[] }
  | { event: 'seat_booked';   seat_ids: string[] };

export function SeatSelectionPage() {
  const { id: showId } = useParams<{ id: string }>();
  const nav = useNavigate();
  const [selected, setSelected] = useState<Set<string>>(new Set());

  const { data, isLoading, refetch } = useQuery({
    queryKey: ['show-seats', showId],
    queryFn:  () => Shows.seats(showId!),
    refetchInterval: 30_000
  });
  const [seats, setSeats] = useState<Seat[]>([]);
  useEffect(() => { if (data?.seats) setSeats(data.seats); }, [data]);

  useChannel<RealtimeEvent>({ channel: 'SeatChannel', show_id: showId },
    (msg) => {
      setSeats(prev => prev.map(s => {
        if (!msg.seat_ids.includes(s.id)) return s;
        if (msg.event === 'seat_booked')   return { ...s, state: 'booked' };
        if (msg.event === 'seat_locked')   return { ...s, state: 'locked' };
        if (msg.event === 'seat_released') return { ...s, state: 'available' };
        return s;
      }));
      if (msg.event === 'seat_booked' || msg.event === 'seat_locked') {
        setSelected(prev => {
          const next = new Set(prev);
          msg.seat_ids.forEach(id => next.delete(id));
          return next;
        });
      }
    },
    [showId]
  );

  const toggle = (id: string) => {
    setSelected(prev => {
      const next = new Set(prev);
      next.has(id) ? next.delete(id) : next.add(id);
      if (next.size > 10) { toast.error('Max 10 seats per booking'); return prev; }
      return next;
    });
  };

  const subtotal = useMemo(
    () => seats.filter(s => selected.has(s.id)).reduce((sum, s) => sum + Number(s.price), 0),
    [seats, selected]
  );

  const proceed = useMutation({
    mutationFn: async () => {
      const seatIds = Array.from(selected);
      const lock    = await Shows.lockSeats(showId!, seatIds);
      const idem    = crypto.randomUUID();
      const booking = await Bookings.create(
        { show_id: showId!, seat_ids: seatIds, lock_token: lock.lock_token, payment_provider: 'stripe' },
        idem
      );
      return booking;
    },
    onSuccess: (b) => nav(`/checkout/${b.id}`),
    onError: (err: any) => {
      toast.error(err.response?.data?.error?.message ?? 'Could not reserve seats');
      refetch();
    }
  });

  if (isLoading || !data) return <div className="max-w-7xl mx-auto px-4 py-10 text-slate-500">Loading seats…</div>;

  return (
    <div className="max-w-5xl mx-auto px-4 py-8">
      <div className="mb-6">
        <h1 className="text-xl font-bold text-slate-900">{data.show.movie.title}</h1>
        <p className="text-sm text-slate-500">
          {data.show.theater.name} · {data.show.screen.name} ·{' '}
          {new Date(data.show.starts_at).toLocaleString()}
        </p>
      </div>

      <div className="card p-6">
        <SeatMap seats={seats} selected={selected} onToggle={toggle} />
      </div>

      <div className="sticky bottom-3 mt-6">
        <div className="card p-4 flex items-center justify-between gap-3">
          <div>
            <div className="text-sm text-slate-500">{selected.size} seat(s) selected</div>
            <div className="font-bold text-lg text-slate-900">${subtotal.toFixed(2)}</div>
          </div>
          <button
            onClick={() => proceed.mutate()}
            disabled={selected.size === 0 || proceed.isPending}
            className="btn-primary disabled:opacity-40 disabled:cursor-not-allowed"
          >
            {proceed.isPending ? 'Reserving…' : 'Proceed to pay'}
          </button>
        </div>
      </div>
    </div>
  );
}
