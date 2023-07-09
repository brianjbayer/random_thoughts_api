# frozen_string_literal: true

require_relative 'errors/unauthorized_response'

RSpec.shared_examples 'jwt_authorization' do
  context 'when no authorization' do
    before do
      request_without_jwt
    end

    it_behaves_like 'unauthorized response', 'Nil JSON web token'
  end

  context 'when JWT is revoked' do
    let(:jwt) { valid_jwt(user) }

    before do
      # Ensure jwt created before revoking
      jwt
      user.revoke_auth
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Unauthorized: User logged out or access revoked'
  end

  context 'when JWT user has been deleted' do
    let(:jwt) { valid_jwt(user) }

    before do
      # Ensure jwt created before deleting user
      jwt
      user.destroy!
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Unauthorized: User has been deleted'
  end

  context 'when JWT has wrong encoding' do
    let(:jwt) { invalid_algorithm_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Expected a different algorithm'
  end

  context 'when JWT has invalid signature' do
    let(:jwt) { invalid_signature_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Signature verification failed'
  end

  context 'when JWT has invalid audience' do
    let(:jwt) { invalid_audience_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Invalid audience'
  end

  context 'when JWT has invalid issuer' do
    let(:jwt) { invalid_issuer_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Invalid issuer'
  end

  context 'when JWT has expired' do
    let(:jwt) { expired_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Signature has expired'
  end

  context 'when JWT is misssing "user" claim' do
    let(:jwt) { missing_user_claim_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Missing required claim user'
  end

  context 'when JWT is misssing "auth" claim' do
    let(:jwt) { missing_auth_claim_jwt(user) }

    before do
      request_with_jwt
    end

    it_behaves_like 'unauthorized response', 'Missing required claim auth'
  end
end
