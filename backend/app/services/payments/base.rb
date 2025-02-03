module Payments
  # Provider contract. Every concrete provider MUST implement:
  #   * create_intent(booking:, idempotency_key:) -> Payment
  #   * refund(payment:, reason: nil)             -> Payment
  #   * verify_webhook(payload:, signature:)      -> Hash (provider event)
  #   * handle_event(event)                       -> Payment (or nil)
  class Base
    def create_intent(*); raise NotImplementedError; end
    def refund(*);        raise NotImplementedError; end
    def verify_webhook(*); raise NotImplementedError; end
    def handle_event(*);  raise NotImplementedError; end
  end
end
