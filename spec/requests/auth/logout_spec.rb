# frozen_string_literal: true

require 'rails_helper'

require_relative '../../support/helpers/jwt_helper'
require_relative '../../support/shared_examples/jwt_authorization'

RSpec.describe 'delete /login' do
  include JwtHelper

  let(:user) { create(:user) }

  describe 'authorization' do
    let(:request_without_jwt) { delete logout_path }
    let(:request_with_jwt) { logout(jwt) }

    it_behaves_like 'jwt_authorization'
  end

  context 'when authorized' do
    let(:valid_auth_jwt) { valid_jwt(user) }

    before do |example|
      logout(valid_auth_jwt) unless example.metadata[:skip_before]
    end

    # TODO: Should this be user.id instead of email?
    it 'logs that the user has been logged out', :skip_before do
      allow(Rails.logger).to receive(:info)
      logout(valid_auth_jwt)
      expect(Rails.logger).to have_received(:info).with("Logout: Logged out user [#{user.email}]")
    end

    it 'revokes users authorization' do
      expect(user.reload.auth_revoked?(auth_value(valid_auth_jwt))).to be(true)
    end

    it 'returns "message" indicating user logged out successfully' do
      expect(json_body['message']).to include('User logged out successfully')
    end
  end

  private

  def logout(jwt)
    delete logout_path, headers: authorization_header(jwt)
  end
end
