# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/same_user_response'
require_relative '../support/shared_examples/unauthorized_response'

RSpec.describe 'get /user/{id}' do
  include JwtHelper

  context 'when authorized' do
    context "when {id} is current user's id" do
      let(:user) { create(:user) }
      let(:jwt) { valid_jwt(user) }

      before do
        get_user(user, jwt)
      end

      it_behaves_like 'same user response'
    end

    context "when {id} is different user's id" do
      let(:jwt) { valid_jwt(create(:user)) }
      let(:user) { create(:user) }

      before do
        get_user(user, jwt)
      end

      it 'only returns "display_name"' do
        expect(json_body.keys).to eql(['display_name'])
      end

      it 'returns "display_name": display_name of requested user' do
        expect(json_body['display_name']).to eql(user.display_name)
      end
    end

    context 'when {id} does not exist' do
      let(:user) { create(:user) }
      let(:jwt) { valid_jwt(user) }
      let(:not_user) { build(:user).id = 0 }

      before do
        get_user(not_user, jwt)
      end

      it_behaves_like 'not_found response'
    end
  end

  # TODO: Duplicated (diff is get user_path(user)) - Refactor with logout_spec
  context 'when no authorization' do
    subject(:request) { get user_path(user), params: {} }

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
      get_user(user, jwt)
    end

    it_behaves_like 'unauthorized response', 'Unauthorized: User logged out or access revoked'
  end

  context 'when JWT has invalid encoding' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_algorithm_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Expected a different algorithm'
  end

  context 'when JWT has invalid signature' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_signature_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Signature verification failed'
  end

  context 'when JWT has invalid audience' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_audience_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Invalid audience'
  end

  context 'when JWT has invalid issuer' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_issuer_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Invalid issuer'
  end

  context 'when JWT has expired' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { expired_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Signature has expired'
  end

  context 'when JWT is misssing "user" claim' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { missing_user_claim_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Missing required claim user'
  end

  context 'when JWT is misssing "auth" claim' do
    subject(:request) { get_user(user, jwt) }

    let(:user) { create(:user) }
    let(:jwt) { missing_auth_claim_jwt(user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Missing required claim auth'
  end

  private

  def get_user(user, jwt)
    get user_path(user), headers: authorization_header(jwt)
  end
end
