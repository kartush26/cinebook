module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user_id

    def connect
      self.current_user_id = find_verified_user_id
    end

    private

    def find_verified_user_id
      token = request.params[:token].presence || cookies[:cinebook_access_token]
      return nil if token.blank?

      payload = Auth::JwtService.decode!(token)
      payload['sub']
    rescue Auth::Errors::Unauthorized
      nil # anonymous WS connections allowed (read-only seat map)
    end
  end
end
