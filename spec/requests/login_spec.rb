# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/login_helper'
require_relative '../support/shared_examples/unauthorized_response'

class LoginMessage
  def self.invalid_login
    'Invalid login'
  end
end

RSpec.describe 'post /login' do
  include LoginHelper

  let(:valid_user) { create(:user) }

  context 'when valid login credentials' do
    let(:secret) { Rails.configuration.jwt_secret }
    let(:decoded_jwt) { JWT.decode(json_body['token'], secret, true, { algorithm: 'HS256' }) }
    let(:jwt_claims) { decoded_jwt.first }

    before do |example|
      post_login(valid_user) unless example.metadata[:skip_before]
    end

    it 'logs that the user has been authenticated', :skip_before do
      allow(Rails.logger).to receive(:info)
      post_login(valid_user)
      expect(Rails.logger).to have_received(:info).with("Login: Authenticated user [#{valid_user.email}]")
    end

    it 'returns HS256-encoded JWT in "token"' do
      expect { decoded_jwt }.not_to raise_error
    end

    it 'returns JWT with "user:" id' do
      expect(jwt_claims['user']).to eql(valid_user.id)
    end

    it 'returns "message" indicating user logged in successfully' do
      expect(json_body['message']).to include('User logged in successfully')
    end
  end

  context 'when incorrect password' do
    before do
      valid_user.password = 'invalid'
      post_login(valid_user)
    end

    it_behaves_like 'unauthorized response', LoginMessage.invalid_login
  end

  context 'when incorrect email' do
    before do
      valid_user.email = 'invalid@wrong.com'
      post_login(valid_user)
    end

    it_behaves_like 'unauthorized response', LoginMessage.invalid_login
  end

  private

  def post_login(user)
    post login_path, params: build_login_body(user)
  end
end
