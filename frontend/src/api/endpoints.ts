import { api, ApiEnvelope } from './client';

export type Movie = {
  id: string; title: string; synopsis: string; duration_minutes: number;
  language: string; rating: string; genres: string[]; cast: string[];
  director: string; trailer_url?: string; release_date: string;
  status: string; imdb_rating: number;
  poster_url?: string; banner_url?: string;
  shows?: Show[];
};

export type Show = {
  id: string; starts_at: string; ends_at: string; language: string;
  movie:   { id: string; title: string; language: string };
  screen:  { id: string; name: string; screen_type: string };
  theater: { id: string; name: string; city: string };
};

export type Seat = {
  id: string; row_label: string; column_index: number; label: string;
  category: string; base_price: number; price: number; state: 'available' | 'locked' | 'booked';
};

export type Booking = {
  id: string; reference: string; status: string; total_amount: number;
  currency: string; seats_count: number; confirmed_at?: string;
  show: { id: string; starts_at: string; movie: { id: string; title: string }; theater: { id: string; name: string }; screen: { id: string; name: string } };
  seats: { id: string; label: string; price: number }[];
  payment?: { provider: string; status: string; client_secret?: string; external_id?: string; amount: number };
};

export const Movies = {
  list:     (params: { q?: string; language?: string; genre?: string; page?: number } = {}) =>
            api.get<ApiEnvelope<Movie[]>>('/api/v1/movies', { params }).then(r => r.data),
  show:     (id: string) =>
            api.get<ApiEnvelope<Movie>>(`/api/v1/movies/${id}`).then(r => r.data.data),
  featured: () =>
            api.get<ApiEnvelope<Movie[]>>('/api/v1/movies/featured').then(r => r.data.data)
};

export const Shows = {
  byTheater: (theaterId: string, params: { movie_id?: string; date?: string } = {}) =>
             api.get<ApiEnvelope<Show[]>>(`/api/v1/theaters/${theaterId}/shows`, { params }).then(r => r.data.data),
  show:      (id: string) => api.get<ApiEnvelope<Show>>(`/api/v1/shows/${id}`).then(r => r.data.data),
  seats:     (id: string) => api.get<ApiEnvelope<{ show: Show; screen: any; seats: Seat[] }>>(`/api/v1/shows/${id}/seats`).then(r => r.data.data),
  lockSeats: (id: string, seatIds: string[]) =>
             api.post<ApiEnvelope<{ lock_token: string; expires_at: string; seat_ids: string[] }>>(
               `/api/v1/shows/${id}/lock_seats`, { seat_ids: seatIds }
             ).then(r => r.data.data)
};

export const Bookings = {
  list:    () => api.get<ApiEnvelope<Booking[]>>('/api/v1/bookings').then(r => r.data),
  show:    (id: string) => api.get<ApiEnvelope<Booking>>(`/api/v1/bookings/${id}`).then(r => r.data.data),
  create:  (payload: { show_id: string; seat_ids: string[]; lock_token: string; payment_provider?: string }, idempotencyKey: string) =>
           api.post<ApiEnvelope<Booking>>('/api/v1/bookings', { booking: payload },
             { headers: { 'Idempotency-Key': idempotencyKey } }).then(r => r.data.data),
  confirm: (id: string) => api.post<ApiEnvelope<Booking>>(`/api/v1/bookings/${id}/confirm`).then(r => r.data.data),
  cancel:  (id: string) => api.post<ApiEnvelope<Booking>>(`/api/v1/bookings/${id}/cancel`).then(r => r.data.data)
};

export const Auth = {
  signup: (user: { email: string; name: string; password: string }) =>
          api.post('/api/v1/auth/signup', { user }).then(r => r.data.data),
  login:  (email: string, password: string) =>
          api.post('/api/v1/auth/login', { email, password }).then(r => r.data.data),
  logout: (refresh_token: string) =>
          api.delete('/api/v1/auth/logout', { data: { refresh_token } })
};

export const Theaters = {
  list: (city?: string) => api.get<ApiEnvelope<any[]>>('/api/v1/theaters', { params: { city } }).then(r => r.data.data)
};
