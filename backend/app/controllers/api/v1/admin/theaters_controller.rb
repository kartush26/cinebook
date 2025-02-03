module API
  module V1
    module Admin
      class TheatersController < ApplicationController
        def index
          scope = Theater.order(:name).page(params[:page]).per(params[:per_page] || 25)
          render_success(TheaterSerializer.render_as_hash(scope), meta: pagination_meta(scope))
        end

        def show
          render_success(TheaterSerializer.render_as_hash(Theater.find(params[:id]), view: :detail))
        end

        def create
          theater = Theater.create!(theater_params)
          render_success(TheaterSerializer.render_as_hash(theater), status: :created)
        end

        def update
          theater = Theater.find(params[:id])
          theater.update!(theater_params)
          render_success(TheaterSerializer.render_as_hash(theater))
        end

        def destroy
          Theater.find(params[:id]).update!(active: false)
          head :no_content
        end

        private

        def theater_params
          params.require(:theater).permit(:name, :city, :address, :latitude, :longitude, :active)
        end
      end
    end
  end
end
