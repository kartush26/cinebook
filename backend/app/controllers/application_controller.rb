class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :set_request_id
  before_action :authenticate_user!

  skip_before_action :authenticate_user!, only: :route_not_found, raise: false

  attr_reader :current_user

  rescue_from ActiveRecord::RecordNotFound,        with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid,         with: :render_unprocessable
  rescue_from ActiveRecord::RecordNotUnique,       with: :render_conflict
  rescue_from ActionController::ParameterMissing,  with: :render_bad_request
  rescue_from Pundit::NotAuthorizedError,          with: :render_forbidden
  rescue_from Auth::Errors::Unauthorized,          with: :render_unauthorized
  rescue_from Bookings::Errors::SeatUnavailable,    with: ->(e) { render_error(:conflict, e.message, code: 'seat_unavailable') }
  rescue_from Bookings::Errors::LockExpired,        with: ->(e) { render_error(:gone,     e.message, code: 'lock_expired') }

  def route_not_found
    render_error(:not_found, 'Endpoint not found', code: 'route_not_found')
  end

  private

  def authenticate_user!
    token = bearer_token
    raise Auth::Errors::Unauthorized, 'Missing access token' if token.blank?

    payload = Auth::JwtService.decode!(token)
    @current_user = User.find(payload['sub'])
    RequestStore.store[:current_user_id] = @current_user.id
  rescue ActiveRecord::RecordNotFound, Auth::Errors::Unauthorized
    raise Auth::Errors::Unauthorized, 'Invalid or expired token'
  end

  def bearer_token
    request.headers['Authorization'].to_s.split(' ', 2).last if request.headers['Authorization'].to_s.start_with?('Bearer ')
  end

  def set_request_id
    RequestStore.store[:request_id] = request.request_id
    response.set_header('X-Request-Id', request.request_id)
  end

  def pagination_meta(scope)
    {
      current_page: scope.current_page,
      total_pages:  scope.total_pages,
      total_count:  scope.total_count,
      per_page:     scope.limit_value
    }
  end

  # ---------- error renderers ----------
  def render_not_found(exception);    render_error(:not_found,    exception.message, code: 'not_found'); end
  def render_unprocessable(exception);render_error(:unprocessable_entity, exception.record.errors.full_messages.join(', '), code: 'validation_error', details: exception.record.errors); end
  def render_conflict(exception);     render_error(:conflict,     exception.message, code: 'conflict'); end
  def render_bad_request(exception);  render_error(:bad_request,  exception.message, code: 'bad_request'); end
  def render_unauthorized(exception); render_error(:unauthorized, exception.message, code: 'unauthorized'); end
  def render_forbidden(exception);    render_error(:forbidden,    'Not authorized', code: 'forbidden'); end

  def render_error(status, message, code:, details: nil)
    render json: { error: { code: code, message: message, details: details }.compact }, status: status
  end

  def render_success(data, status: :ok, meta: nil)
    body = { data: data }
    body[:meta] = meta if meta
    render json: body, status: status
  end
end
