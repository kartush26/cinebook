import { useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useQuery, useMutation } from '@tanstack/react-query';
import toast from 'react-hot-toast';
import { Elements, useStripe, useElements, CardElement } from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';
import { Bookings } from '@/api/endpoints';

const stripePromise = loadStripe(import.meta.env.VITE_STRIPE_PUBLISHABLE_KEY ?? '');

export function CheckoutPage() {
  const { bookingId } = useParams<{ bookingId: string }>();
  const { data: booking, isLoading, refetch } = useQuery({
    queryKey: ['booking', bookingId],
    queryFn: () => Bookings.show(bookingId!),
    refetchInterval: (q) => (q.state.data?.status === 'pending' ? 4000 : false)
  });

  if (isLoading || !booking) return <div className="max-w-3xl mx-auto px-4 py-10 text-slate-500">Loading…</div>;

  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <h1 className="text-xl font-bold text-slate-900">Checkout</h1>
      <p className="text-sm text-slate-500 mb-6">Reference: {booking.reference}</p>

      <div className="card p-5 mb-6">
        <div className="flex justify-between mb-2"><span className="text-slate-500">Movie</span><span className="text-slate-900 font-medium">{booking.show.movie.title}</span></div>
        <div className="flex justify-between mb-2"><span className="text-slate-500">Theater</span><span className="text-slate-900">{booking.show.theater.name}</span></div>
        <div className="flex justify-between mb-2"><span className="text-slate-500">Showtime</span><span className="text-slate-900">{new Date(booking.show.starts_at).toLocaleString()}</span></div>
        <div className="flex justify-between mb-2"><span className="text-slate-500">Seats</span><span className="text-slate-900">{booking.seats.map(s => s.label).join(', ')}</span></div>
        <div className="flex justify-between mt-3 pt-3 border-t border-slate-200 font-bold text-lg text-slate-900">
          <span>Total</span><span>${booking.total_amount}</span>
        </div>
      </div>

      {booking.status === 'confirmed' ? (
        <ConfirmedView bookingId={booking.id} />
      ) : booking.payment?.client_secret ? (
        <Elements stripe={stripePromise} options={{ clientSecret: booking.payment.client_secret, appearance: { theme: 'stripe' } }}>
          <PaymentForm bookingId={booking.id} clientSecret={booking.payment.client_secret} onPaid={() => refetch()} />
        </Elements>
      ) : (
        <p className="text-amber-600">Awaiting payment intent…</p>
      )}
    </div>
  );
}

function PaymentForm({ bookingId, clientSecret, onPaid }: { bookingId: string; clientSecret: string; onPaid: () => void }) {
  const stripe = useStripe();
  const elements = useElements();
  const [submitting, setSubmitting] = useState(false);

  const confirm = useMutation({ mutationFn: () => Bookings.confirm(bookingId) });

  const onPay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!stripe || !elements) return;
    setSubmitting(true);
    const card = elements.getElement(CardElement)!;
    const { error, paymentIntent } = await stripe.confirmCardPayment(clientSecret, { payment_method: { card } });
    setSubmitting(false);
    if (error) { toast.error(error.message ?? 'Payment failed'); return; }
    if (paymentIntent?.status === 'succeeded') {
      toast.success('Payment successful');
      await confirm.mutateAsync();
      onPaid();
    }
  };

  return (
    <form onSubmit={onPay} className="card p-5 space-y-4">
      <label className="block text-sm">
        <span className="text-slate-700 font-medium mb-2 block">Card details</span>
        <div className="p-3 rounded-lg bg-white border border-slate-200">
          <CardElement options={{ style: { base: { color: '#0f172a', fontSize: '15px', '::placeholder': { color: 'rgba(0,0,0,0.3)' } } } }} />
        </div>
        <p className="text-xs text-slate-400 mt-2">Test card: 4242 4242 4242 4242 · any future date · any CVC</p>
      </label>
      <button className="btn-primary w-full" disabled={!stripe || submitting}>{submitting ? 'Processing…' : 'Pay now'}</button>
    </form>
  );
}

function ConfirmedView({ bookingId }: { bookingId: string }) {
  const nav = useNavigate();
  useEffect(() => { toast.success('Booking confirmed!'); }, []);
  return (
    <div className="card p-6 text-center">
      <h2 className="text-xl font-bold text-slate-900">🎉 Booking confirmed</h2>
      <p className="text-slate-500 mt-1">Your tickets are in your bookings list and emailed to you.</p>
      <div className="flex gap-3 justify-center mt-5">
        <button onClick={() => nav('/bookings')} className="btn-primary">View bookings</button>
        <button onClick={() => nav('/')} className="btn-ghost">Home</button>
      </div>
      <p className="text-xs text-slate-400 mt-3">Booking id: {bookingId}</p>
    </div>
  );
}
