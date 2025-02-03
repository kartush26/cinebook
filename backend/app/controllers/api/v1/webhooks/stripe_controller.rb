module API
  module V1
    module Webhooks
      class StripeController < ActionController::API
        # Endpoint must be public — auth via signature header only.
        def receive
          payload   = request.body.read
          signature = request.headers['Stripe-Signature']

          begin
            event = Payments::Stripe::Provider.new.verify_webhook(payload: payload, signature: signature)
          rescue SecurityError => e
            return render json: { error: e.message }, status: :bad_request
          end

          record = WebhookEvent.find_or_create_by!(
            provider:    'stripe',
            external_id: event['id']
          ) do |we|
            we.event_type = event['type']
            we.payload    = event.to_hash
          end

          if record.processed?
            return head :ok # idempotent replay
          end

          begin
            Payments::Stripe::Provider.new.handle_event(event)
            record.mark_processed!
            head :ok
          rescue StandardError => e
            record.mark_failed!(e)
            Rails.logger.error("[stripe webhook] #{e.class}: #{e.message}")
            render json: { error: 'processing_failed' }, status: :internal_server_error
          end
        end
      end
    end
  end
end
