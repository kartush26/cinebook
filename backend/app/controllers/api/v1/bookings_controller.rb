module API
  module V1
    class BookingsController < ApplicationController
      def index
        scope = policy_scope(::Booking)
                  .includes(:show, booking_seats: :seat, show: { screen: :theater })
                  .recent
                  .page(params[:page]).per(params[:per_page] || 20)
        render_success(BookingSerializer.render_as_hash(scope), meta: pagination_meta(scope))
      end

      def show
        booking = ::Booking.includes(:payment, booking_seats: :seat, show: { screen: :theater }).find(params[:id])
        authorize booking
        render_success(BookingSerializer.render_as_hash(booking, view: :with_payment))
      end

      def create
        result = ::Bookings::CreateService.new(
          user:             current_user,
          show_id:          create_params[:show_id],
          seat_ids:         create_params[:seat_ids],
          lock_token:       create_params[:lock_token],
          payment_provider: create_params.fetch(:payment_provider, 'stripe'),
          idempotency_key:  request.headers['Idempotency-Key'] || create_params[:idempotency_key]
        ).call

        render_success(
          BookingSerializer.render_as_hash(result.booking.reload, view: :with_payment),
          status: :created
        )
      end

      # Confirms a booking from the frontend after Stripe.confirmPayment succeeds
      # (defensive — the webhook is the real source of truth).
      def confirm
        booking = ::Booking.find(params[:id])
        authorize booking, :confirm?
        ::Bookings::ConfirmService.call(booking)
        render_success(BookingSerializer.render_as_hash(booking.reload, view: :with_payment))
      end

      def cancel
        booking = ::Booking.find(params[:id])
        authorize booking, :cancel?
        ::Bookings::CancelService.call(booking, reason: params[:reason])
        render_success(BookingSerializer.render_as_hash(booking.reload, view: :with_payment))
      end

      private

      def create_params
        params.require(:booking).permit(:show_id, :lock_token, :payment_provider, :idempotency_key, seat_ids: [])
      end
    end
  end
end
