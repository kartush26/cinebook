module Payments
  module Phonepe
    class WebhookHandler
      def initialize(event); @event = event; end

      def process
        case @event['code']
        when 'PAYMENT_SUCCESS'
          payment = ::Payment.find_by(external_id: @event.dig('data', 'merchantTransactionId'))
          ::Bookings::ConfirmService.call(payment.booking, payment_external_id: payment.external_id) if payment
        when 'PAYMENT_ERROR', 'PAYMENT_DECLINED'
          payment = ::Payment.find_by(external_id: @event.dig('data', 'merchantTransactionId'))
          payment&.update!(status: :failed)
        end
      end
    end
  end
end
