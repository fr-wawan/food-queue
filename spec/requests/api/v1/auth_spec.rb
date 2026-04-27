require 'rails_helper'

RSpec.describe "Api::V1::Auths", type: :request do
  let(:restaurant) { create(:restaurant) }
  let(:user) { create(:user, restaurant: restaurant, password: "password123") }

  describe "POST /api/v1/auth/login" do
    let(:valid_params) do
      {
        subdomain: restaurant.subdomain,
        email: user.email,
        password: "password123"
      }
    end

    context "with valid credentials" do
      it "returns token and user" do
        post "/api/v1/auth/login", params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
        expect(json['token']).to be_present
        expect(json['user']['email']).to eq(user.email)
      end

      it 'create session record in DB' do
        expect {
          post "/api/v1/auth/login", params: valid_params, as: :json
        }.to change(Session, :count).by(1)
      end
    end

    context 'with wrong password' do
      it 'returns 401' do
        post "/api/v1/auth/login",
          params: valid_params.merge(password: "salah"),
          as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with subdomain that isn't exists" do
      it 'returns 404' do
        post "/api/v1/auth/login",
          params: valid_params.merge(subdomain: "tidak-ada"),
          as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with nonexistent email' do
      it 'returns 404' do
        post '/api/v1/auth/login',
          params: valid_params.merge(email: "noexist@test.com"),
          as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    describe 'DELETE /api/v1/auth/logout' do
      context 'with valid token' do
        it 'delete session and return 204' do
          headers = auth_headers(user)

          expect {
            delete "/api/v1/auth/logout", headers: headers
          }.to change(Session, :count).by(-1)

          expect(response).to have_http_status(:no_content)
        end
      end

      context 'without token' do
        it 'returns 401' do
          delete "/api/v1/auth/logout"
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with expired token' do
        it 'returns 401' do
          headers = auth_headers(user)

          user.sessions.last.update!(expires_at: 1.hour.ago)

          delete "/api/v1/auth/logout", headers: headers

          expect(response).to have_http_status(:unauthorized)
        end
      end
    end
  end
end
