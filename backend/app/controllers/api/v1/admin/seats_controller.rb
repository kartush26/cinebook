module API
  module V1
    module Admin
      class SeatsController < ApplicationController
        def index
          render_success(SeatSerializer.render_as_hash(Screen.find(params[:screen_id]).seats.order(:row_label, :column_index)))
        end

        # Bulk-create seats from a layout description.
        def create
          screen = Screen.find(params[:screen_id])
          ::Screen::SeatLayoutBuilder.new(screen, layout: params[:layout]).build!
          render_success(SeatSerializer.render_as_hash(screen.seats.order(:row_label, :column_index)), status: :created)
        end

        def destroy
          Seat.find(params[:id]).destroy!
          head :no_content
        end
      end
    end
  end
end
