module API
  module V1
    module Admin
      class ScreensController < ApplicationController
        def index
          theater = Theater.find(params[:theater_id])
          render_success(ScreenSerializer.render_as_hash(theater.screens.order(:name)))
        end

        def show
          render_success(ScreenSerializer.render_as_hash(Screen.find(params[:id])))
        end

        def create
          theater = Theater.find(params[:theater_id])
          screen  = theater.screens.create!(screen_params)
          ::Screen::SeatLayoutBuilder.new(screen).build! if params[:seat_layout].present?
          render_success(ScreenSerializer.render_as_hash(screen), status: :created)
        end

        def update
          screen = Screen.find(params[:id])
          screen.update!(screen_params)
          render_success(ScreenSerializer.render_as_hash(screen))
        end

        def destroy
          Screen.find(params[:id]).destroy!
          head :no_content
        end

        private

        def screen_params
          params.require(:screen).permit(:name, :rows, :columns, :screen_type)
        end
      end
    end
  end
end
