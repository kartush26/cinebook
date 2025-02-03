module AuthHelpers
  def auth_headers_for(user)
   token = Auth::JwtService.encode(
      {
        sub: user.id,
        role: user.role,
        name: user.name
      }
    )
    { 'Authorization' => "Bearer #{token}" }
  end

  def json
    JSON.parse(response.body)
  end
end
