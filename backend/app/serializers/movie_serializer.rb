class MovieSerializer < Blueprinter::Base
  identifier :id

  fields :title, :synopsis, :duration_minutes, :language, :rating,
         :genres, :cast, :director, :trailer_url, :release_date,
         :status, :imdb_rating

  field :poster_url do |movie|
    Rails.application.routes.url_helpers.rails_blob_url(movie.poster) if movie.poster.attached?
  end

  field :banner_url do |movie|
    Rails.application.routes.url_helpers.rails_blob_url(movie.banner) if movie.banner.attached?
  end

  view :detail do
    association :upcoming_shows, blueprint: ShowSerializer, name: :shows do |movie|
      movie.shows.upcoming.includes(screen: :theater).order(:starts_at).limit(50)
    end
  end
end
