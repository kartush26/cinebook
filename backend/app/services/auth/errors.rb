module Auth
  module Errors
    class Unauthorized < StandardError; end
    class TokenReused  < StandardError; end
  end
end
