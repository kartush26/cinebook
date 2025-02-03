module API
  module V1
    module Admin
      class BaseController < ApplicationController
        before_action :require_admin!

        private

        def require_admin!
          raise Pundit::NotAuthorizedError unless current_user&.admin?
        end
      end
    end
  end
end
