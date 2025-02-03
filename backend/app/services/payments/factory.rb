module Payments
  class Factory
    REGISTRY = {
      'stripe'  => -> { Payments::Stripe::Provider.new },
      'phonepe' => -> { Payments::Phonepe::Provider.new }
    }.freeze

    def self.for(provider)
      builder = REGISTRY[provider.to_s]
      raise ArgumentError, "Unsupported payment provider: #{provider}" unless builder

      builder.call
    end
  end
end
