class ShowSerializer < Blueprinter::Base
  identifier :id

  fields :starts_at, :ends_at, :price_multiplier, :status, :language

  field :movie do |show|
    { id: show.movie_id, title: show.movie.title, language: show.movie.language }
  end

  field :screen do |show|
    { id: show.screen_id, name: show.screen.name, screen_type: show.screen.screen_type }
  end

  field :theater do |show|
    { id: show.screen.theater_id, name: show.screen.theater.name, city: show.screen.theater.city }
  end
end
