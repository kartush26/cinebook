module API
  module V1
    class ShowsController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[show seats]

      def show
        show = Show.includes(:movie, screen: :theater).find(params[:id])
        render_success(ShowSerializer.render_as_hash(show))
      end

      # Returns the seat-map for a show with live availability:
      # available | booked | locked
      def seats
        show = Show.includes(screen: :seats).find(params[:id])
        booked_ids = show.booked_seat_ids.to_set
        locked_ids = Bookings::SeatLockService.locked_seat_ids_for(show.id).to_set

        seat_map = show.screen.seats.order(:row_label, :column_index).map do |seat|
          state = if booked_ids.include?(seat.id)
                    'booked'
                  elsif locked_ids.include?(seat.id)
                    'locked'
                  else
                    'available'
                  end
          SeatSerializer.render_as_hash(seat).merge(
            state: state,
            price: show.price_for(seat)
          )
        end

        render_success({
          show:   ShowSerializer.render_as_hash(show),
          screen: ScreenSerializer.render_as_hash(show.screen),
          seats:  seat_map
        })
      end

      def lock_seats
        authenticate_user!
        seat_ids = Array(params[:seat_ids]).map(&:to_s).uniq
        raise ActionController::ParameterMissing, :seat_ids if seat_ids.empty?

        result = Bookings::SeatLockService.lock!(
          show_id: params[:id],
          seat_ids: seat_ids,
          user_id: current_user.id
        )
        render_success({
          lock_token: result.lock_token,
          expires_at: result.expires_at.iso8601,
          seat_ids:   seat_ids
        })
      end
    end
  end
end
