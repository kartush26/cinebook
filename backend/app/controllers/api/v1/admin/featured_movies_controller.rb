module API
  module V1
    module Admin
      class FeaturedMoviesController < ApplicationController
        def index
          render_success(FeaturedMovie.current.includes(:movie).map do |fm|
            { id: fm.id, position: fm.position, starts_on: fm.starts_on, ends_on: fm.ends_on,
              movie: MovieSerializer.render_as_hash(fm.movie) }
          end)
        end

        def create
          fm = FeaturedMovie.create!(featured_params)
          render_success(MovieSerializer.render_as_hash(fm.movie), status: :created)
        end

        def destroy
          FeaturedMovie.find(params[:id]).destroy!
          head :no_content
        end

        private

        def featured_params
          params.require(:featured_movie).permit(:movie_id, :position, :starts_on, :ends_on)
        end
      end
    end
  end
end
