module API
  module V1
    module Admin
      class AnalyticsController < ApplicationController
        def overview
          today    = Time.current.beginning_of_day
          last_30  = 30.days.ago

          render_success({
            total_bookings:       Booking.confirmed.count,
            bookings_today:       Booking.confirmed.where(created_at: today..).count,
            bookings_last_30:     Booking.confirmed.where(created_at: last_30..).count,
            total_revenue:        Booking.confirmed.sum(:total_amount).to_f,
            revenue_last_30:      Booking.confirmed.where(created_at: last_30..).sum(:total_amount).to_f,
            active_users:         User.where(last_login_at: last_30..).count,
            total_users:          User.count,
            total_movies_showing: Movie.showing.count,
            total_theaters:       Theater.active.count
          })
        end

        def revenue
          from = (params[:from].presence && Date.parse(params[:from])) || 30.days.ago.to_date
          to   = (params[:to].presence   && Date.parse(params[:to]))   || Date.current

          buckets = Booking.confirmed
                           .where(created_at: from.beginning_of_day..to.end_of_day)
                           .group("DATE(created_at)")
                           .select("DATE(created_at) AS day, SUM(total_amount) AS revenue, COUNT(*) AS bookings")

          data = buckets.map { |b| { day: b.day, revenue: b.revenue.to_f, bookings: b.bookings.to_i } }
          render_success(data)
        end

        def occupancy
          window = (params[:days] || 7).to_i.days.ago
          shows = Show.where(starts_at: window..Time.current).includes(:screen, :booking_seats)
          data = shows.map do |show|
            booked = show.booking_seats.where(active: true).count
            capacity = show.screen.total_capacity
            {
              show_id:    show.id,
              starts_at:  show.starts_at,
              theater_id: show.screen.theater_id,
              movie_id:   show.movie_id,
              booked:     booked,
              capacity:   capacity,
              occupancy:  capacity.zero? ? 0 : ((booked.to_f / capacity) * 100).round(2)
            }
          end
          render_success(data)
        end
      end
    end
  end
end
