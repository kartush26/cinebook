# frozen_string_literal: true
# Idempotent seeds: safe to re-run.

puts '🌱 Seeding CineBook...'

# ─── Users ────────────────────────────────────────────────────────────────
admin = User.find_or_create_by!(email: 'admin@cinebook.test') do |u|
  u.name = 'CineBook Admin'
  u.role = :admin
  u.password = 'Admin@12345'
end

user = User.find_or_create_by!(email: 'user@cinebook.test') do |u|
  u.name = 'Demo Viewer'
  u.role = :customer
  u.password = 'User@12345'
end
puts "✓ users: #{User.count}"

# ─── Movies ───────────────────────────────────────────────────────────────
MOVIES = [
  { title: 'Interstellar Awakening', language: 'English', genres: %w[Sci-Fi Drama],
    duration_minutes: 169, rating: 'UA', director: 'Lena Park',
    cast: ['Hugo Ward', 'Aria Vance', 'Kenji Mori'],
    synopsis: 'A scientist races against time across galaxies to bring humanity home.',
    imdb_rating: 8.6, release_date: 2.weeks.ago },
  { title: 'Crimson Pursuit',        language: 'English', genres: %w[Action Thriller],
    duration_minutes: 121, rating: 'A', director: 'Mateo Cruz',
    cast: ['Dax Holland', 'Mira Reyes'],
    synopsis: 'A retired operative is pulled back in for one last mission.',
    imdb_rating: 7.4, release_date: 1.month.ago },
  { title: 'The Quiet Garden',       language: 'English', genres: %w[Drama Romance],
    duration_minutes: 108, rating: 'U', director: 'Saoirse Quinn',
    cast: ['Nora Lin', 'Ben Adler'],
    synopsis: 'Two strangers find unexpected solace in a forgotten courtyard.',
    imdb_rating: 8.1, release_date: 10.days.ago },
  { title: 'Neon Samurai',           language: 'Japanese', genres: %w[Action Anime],
    duration_minutes: 96, rating: 'UA', director: 'Hiroshi Tanaka',
    cast: ['Voice Cast'],
    synopsis: 'A wandering swordsman in a neon-drenched future Tokyo.',
    imdb_rating: 7.9, release_date: 1.week.ago }
].freeze

MOVIES.each do |attrs|
  Movie.find_or_create_by!(title: attrs[:title]) do |m|
    m.assign_attributes(attrs.merge(status: :now_showing))
  end
end
puts "✓ movies: #{Movie.count}"

# ─── Featured (top 4 this week) ────────────────────────────────────────────
Movie.showing.limit(4).each_with_index do |movie, idx|
  FeaturedMovie.find_or_create_by!(movie: movie, position: idx + 1) do |fm|
    fm.starts_on = Time.current.beginning_of_week
    fm.ends_on   = (Time.current.beginning_of_week + 7.days).end_of_day
  end
end
puts "✓ featured: #{FeaturedMovie.count}"

# ─── Theaters + Screens + Seats ────────────────────────────────────────────
THEATERS = [
  { name: 'Cineplex Marina',  city: 'Mumbai', address: '123 Marina Drive, Mumbai' },
  { name: 'Grand Orion Mall', city: 'Bangalore', address: '5th Block, Koramangala, Bangalore' }
].freeze

THEATERS.each do |t_attrs|
  theater = Theater.find_or_create_by!(name: t_attrs[:name]) { |th| th.assign_attributes(t_attrs) }

  2.times do |i|
    screen = theater.screens.find_or_create_by!(name: "Screen #{i + 1}") do |s|
      s.rows    = 8
      s.columns = 12
      s.screen_type = i.zero? ? 'standard' : 'imax'
    end
    next if screen.seats.exists?

    layout = [
      { rows: 'A-B', category: 'premium',  price: i.zero? ? 14.99 : 19.99 },
      { rows: 'C-F', category: 'standard', price: i.zero? ?  9.99 : 12.99 },
      { rows: 'G-H', category: 'recliner', price: i.zero? ? 17.99 : 22.99 }
    ]
    Screen::SeatLayoutBuilder.new(screen, layout: layout).build!
  end
end
puts "✓ theaters/screens/seats — #{Theater.count}/#{Screen.count}/#{Seat.count}"

# ─── Shows ────────────────────────────────────────────────────────────────
SHOW_TIMES = [10, 13, 16, 19, 22].freeze # hours of day
Theater.find_each do |theater|
  theater.screens.each do |screen|
    Movie.showing.find_each do |movie|
      [0, 1].each do |offset|
        date = Date.current + offset
        SHOW_TIMES.sample(2).each do |hour|
          starts_at = Time.zone.local(date.year, date.month, date.day, hour)
          next if Show.exists?(screen: screen, starts_at: starts_at)
          # Skip silently if it overlaps with an already-seeded show — model validation will reject
          Show.create(
            movie: movie, screen: screen, starts_at: starts_at,
            ends_at: starts_at + movie.duration_minutes.minutes,
            price_multiplier: screen.screen_type == 'imax' ? 1.4 : 1.0,
            language: movie.language, status: :scheduled
          ) # not bang — overlaps are allowed to silently skip
        end
      end
    end
  end
end
puts "✓ shows: #{Show.count}"

puts "\n🎬 Done. Login with:"
puts "  admin@cinebook.test / Admin@12345"
puts "  user@cinebook.test  / User@12345"
