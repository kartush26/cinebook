module API
  module V1
    module Webhooks
      class PhonepeController < ActionController::API
        def receive
          payload   = request.body.read
          signature = request.headers['X-VERIFY']

          begin
            event = Payments::Phonepe::Provider.new.verify_webhook(payload: payload, signature: signature)
          rescue SecurityError => e
            return render json: { error: e.message }, status: :bad_request
          end

          record = WebhookEvent.find_or_create_by!(
            provider: 'phonepe',
            external_id: event['transactionId'] || SecureRandom.uuid
          ) do |we|
            we.event_type = event['code'] || 'unknown'
            we.payload    = event
          end

          return head :ok if record.processed?

          Payments::Phonepe::Provider.new.handle_event(event)
          record.mark_processed!
          head :ok
        rescue StandardError => e
          record&.mark_failed!(e) if defined?(record)
          render json: { error: 'processing_failed' }, status: :internal_server_error
        end
      end
    end
  end
end
