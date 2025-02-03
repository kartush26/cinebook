module API
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authenticate_user!, only: %i[signup login refresh]

      def signup
        user = User.create!(signup_params.merge(role: :customer))
        tokens = ::Auth::TokenIssuer.issue_for(user, request: request)
        render_success(token_payload(tokens), status: :created)
      end

      def login
        user = User.find_by(email: params[:email].to_s.downcase)
        raise ::Auth::Errors::Unauthorized, 'Invalid credentials' unless user&.authenticate(params[:password])
        raise ::Auth::Errors::Unauthorized, 'Account disabled' unless user.active?

        user.update_column(:last_login_at, Time.current)
        tokens = ::Auth::TokenIssuer.issue_for(user, request: request)
        render_success(token_payload(tokens))
      end

      def refresh
        raise ::Auth::Errors::Unauthorized, 'Missing refresh token' if params[:refresh_token].blank?

        tokens = ::Auth::TokenIssuer.rotate!(params[:refresh_token], request: request)
        render_success(token_payload(tokens))
      rescue ::Auth::Errors::TokenReused => e
        render_error(:unauthorized, e.message, code: 'token_reused')
      end

      def logout
        ::Auth::TokenIssuer.revoke!(params[:refresh_token]) if params[:refresh_token].present?
        head :no_content
      end

      def me
        render_success(UserSerializer.render_as_hash(current_user))
      end

      private

      def signup_params
        params.require(:user).permit(:email, :name, :password, :phone)
      end

      def token_payload(result)
        {
          access_token:      result.access_token,
          refresh_token:     result.refresh_token,
          access_expires_in: result.access_expires_in,
          token_type:        'Bearer',
          user:              UserSerializer.render_as_hash(result.user)
        }
      end
    end
  end
end
