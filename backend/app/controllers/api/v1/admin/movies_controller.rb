module API
  module V1
    module Admin
      class MoviesController < ApplicationController
        def index
          scope = Movie.search(params[:q]).order(created_at: :desc)
                       .page(params[:page]).per(params[:per_page] || 25)
          render_success(MovieSerializer.render_as_hash(scope), meta: pagination_meta(scope))
        end

        def show
          render_success(MovieSerializer.render_as_hash(Movie.find(params[:id]), view: :detail))
        end

        def create
          movie = Movie.create!(movie_params)
          attach_images(movie)
          render_success(MovieSerializer.render_as_hash(movie), status: :created)
        end

        def update
          movie = Movie.find(params[:id])
          movie.update!(movie_params)
          attach_images(movie)
          render_success(MovieSerializer.render_as_hash(movie))
        end

        def destroy
          Movie.find(params[:id]).update!(status: :archived)
          head :no_content
        end

        private

        def movie_params
          params.require(:movie).permit(:title, :synopsis, :duration_minutes, :language,
                                        :rating, :director, :trailer_url, :release_date,
                                        :status, :imdb_rating,
                                        genres: [], cast: [])
        end

        def attach_images(movie)
          movie.poster.attach(params[:poster]) if params[:poster].present?
          movie.banner.attach(params[:banner]) if params[:banner].present?
        end
      end
    end
  end
end
