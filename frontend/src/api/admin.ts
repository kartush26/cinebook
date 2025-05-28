import { api, ApiEnvelope } from './client';

export const Admin = {
  overview:  () => api.get<ApiEnvelope<any>>('/api/v1/admin/analytics/overview').then(r => r.data.data),
  revenue:   (from?: string, to?: string) => api.get<ApiEnvelope<any[]>>('/api/v1/admin/analytics/revenue',  { params: { from, to } }).then(r => r.data.data),
  occupancy: (days = 7) => api.get<ApiEnvelope<any[]>>('/api/v1/admin/analytics/occupancy', { params: { days } }).then(r => r.data.data),

  movies: {
    list:   () => api.get<ApiEnvelope<any[]>>('/api/v1/admin/movies').then(r => r.data),
    create: (movie: any) => api.post('/api/v1/admin/movies', { movie }).then(r => r.data.data),
    update: (id: string, movie: any) => api.patch(`/api/v1/admin/movies/${id}`, { movie }).then(r => r.data.data),
    remove: (id: string) => api.delete(`/api/v1/admin/movies/${id}`)
  },
  theaters: {
    list:   () => api.get<ApiEnvelope<any[]>>('/api/v1/admin/theaters').then(r => r.data),
    create: (theater: any) => api.post('/api/v1/admin/theaters', { theater }).then(r => r.data.data)
  },
  shows: {
    list:   () => api.get<ApiEnvelope<any[]>>('/api/v1/admin/shows').then(r => r.data),
    create: (show: any) => api.post('/api/v1/admin/shows', { show }).then(r => r.data.data)
  }
};
