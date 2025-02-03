require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'POST /api/v1/auth/signup' do
    it 'creates a user and returns tokens' do
      post '/api/v1/auth/signup', params: {
        user: { email: 'new@user.test', name: 'New User', password: 'Secret@12345' }
      }
      expect(response).to have_http_status(:created)
      expect(json.dig('data', 'access_token')).to be_present
      expect(json.dig('data', 'refresh_token')).to be_present
    end
  end

  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'login@user.test', password: 'Secret@12345') }

    it 'returns tokens with correct credentials' do
      post '/api/v1/auth/login', params: { email: 'login@user.test', password: 'Secret@12345' }
      expect(response).to have_http_status(:ok)
      expect(json.dig('data', 'access_token')).to be_present
    end

    it 'rejects bad password' do
      post '/api/v1/auth/login', params: { email: 'login@user.test', password: 'wrong' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /api/v1/auth/refresh' do
    it 'rotates the refresh token' do
      user = create(:user, password: 'Secret@12345')
      tokens = Auth::TokenIssuer.issue_for(user)

      post '/api/v1/auth/refresh', params: { refresh_token: tokens.refresh_token }
      expect(response).to have_http_status(:ok)
      expect(json.dig('data', 'refresh_token')).not_to eq tokens.refresh_token

      # reuse detection
      post '/api/v1/auth/refresh', params: { refresh_token: tokens.refresh_token }
      expect(response).to have_http_status(:unauthorized)
      expect(json.dig('error', 'code')).to eq 'token_reused'
    end
  end
end
