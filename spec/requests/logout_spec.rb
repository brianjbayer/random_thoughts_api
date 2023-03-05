# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/shared_examples/unauthorized_response'

RSpec.describe 'get /logout' do
  include JwtHelper

  context 'when authorized' do
    let(:user) { create(:user) }
    let(:jwt) { valid_jwt(user) }

    before do |example|
      get_logout(jwt) unless example.metadata[:skip_before]
    end

    # TODO: Should this be user.id instead of email?
    it 'logs that the user has been logged out', :skip_before do
      allow(Rails.logger).to receive(:info)
      get_logout(jwt)
      expect(Rails.logger).to have_received(:info).with("Logout: Logged out user [#{user.email}]")
    end

    it 'revokes users authorization' do
      expect(user.reload.auth_revoked?(auth_value(jwt))).to be(true)
    end

    it 'returns "message" indicating user logged out successfully' do
      expect(json_body['message']).to include('User logged out successfully')
    end
  end

  # TODO: Duplicated (diff is get logout_path) - Refactor with get_user_spec
  context 'when no authorization' do
    subject(:request) { get logout_path }

    let(:user) { create(:user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Nil JSON web token'
  end

  context 'when JWT is revoked' do
    before do
      # Order of operations is critical
      user = create(:user)
      jwt = valid_jwt(user)
      user.revoke_auth
      get_logout(jwt)
    end

    it_behaves_like 'unauthorized response', 'Unauthorized: User logged out or access revoked'
  end

  context 'when JWT has invalid encoding' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_algorithm_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Expected a different algorithm'
  end

  context 'when JWT has invalid signature' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_signature_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Signature verification failed'
  end

  context 'when JWT has invalid audience' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_audience_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Invalid audience'
  end

  context 'when JWT has invalid issuer' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_issuer_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Invalid issuer'
  end

  context 'when JWT has expired' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { expired_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Signature has expired'
  end

  context 'when JWT is misssing "user" claim' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { missing_user_claim_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Missing required claim user'
  end

  context 'when JWT is misssing "auth" claim' do
    subject(:request) { get_logout(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { missing_auth_claim_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Missing required claim auth'
  end

  private

  def get_logout(jwt)
    get logout_path, headers: authorization_header(jwt)
  end
end
