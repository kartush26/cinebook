module API
  module V1
    class MoviesController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[index show featured]

      def index
        scope = Movie.showing
                     .search(params[:q])
                     .by_language(params[:language])
                     .by_genre(params[:genre])
                     .order(release_date: :desc)
                     .page(params[:page]).per(params[:per_page] || 20)

        render_success(MovieSerializer.render_as_hash(scope), meta: pagination_meta(scope))
      end

      def show
        movie = Movie.find(params[:id])
        render_success(MovieSerializer.render_as_hash(movie, view: :detail))
      end

      def featured
        movies = FeaturedMovie.current.includes(:movie).map(&:movie).uniq
        render_success(MovieSerializer.render_as_hash(movies))
      end
    end
  end
end
