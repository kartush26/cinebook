require 'sidekiq'

# Rotates the 4 featured movies every Monday based on a simple heuristic:
# top movies by recent confirmed bookings count.
class WeeklyFeaturedMoviesRotationJob
  include Sidekiq::Job
  sidekiq_options queue: 'low', retry: 2

  def perform
    starts_on = Time.current.beginning_of_day
    ends_on   = (starts_on + 7.days).end_of_day

    FeaturedMovie.where('ends_on < ?', starts_on).delete_all

    top_movie_ids = Booking.confirmed
                           .where('created_at >= ?', 7.days.ago)
                           .joins(:show)
                           .group('shows.movie_id')
                           .order(Arel.sql('COUNT(bookings.id) DESC'))
                           .limit(4)
                           .pluck('shows.movie_id')

    top_movie_ids = Movie.showing.order(release_date: :desc).limit(4).pluck(:id) if top_movie_ids.empty?

    top_movie_ids.first(4).each_with_index do |movie_id, idx|
      FeaturedMovie.create!(movie_id: movie_id, position: idx + 1,
                            starts_on: starts_on, ends_on: ends_on)
    end
  end
end
