module API
  module V1
    module Admin
      class BookingsController < ApplicationController
        def index
          scope = Booking.includes(:user, :payment, show: { screen: :theater })
                         .recent
                         .page(params[:page]).per(params[:per_page] || 25)
          render_success(BookingSerializer.render_as_hash(scope, view: :with_payment), meta: pagination_meta(scope))
        end

        def show
          render_success(BookingSerializer.render_as_hash(Booking.find(params[:id]), view: :with_payment))
        end
      end
    end
  end
end
