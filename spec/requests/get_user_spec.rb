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
      let(:jwt) { valid_jwt(user.id) }

      before do
        get user_path(user), params: {}, headers: authorization_header(jwt)
      end

      it_behaves_like 'same user response'
    end

    context "when {id} is different user's id" do
      let(:jwt) { valid_jwt(create(:user).id) }
      let(:user) { create(:user) }

      before do
        get user_path(user), params: {}, headers: authorization_header(jwt)
      end

      it 'only returns "display_name"' do
        expect(json_body.keys).to eql(['display_name'])
      end

      it 'returns "display_name": display_name of requested user' do
        expect(json_body['display_name']).to eql(user.display_name)
      end
    end

    context 'when {id} does not exist' do
      let(:id) { create(:user).id }
      let(:jwt) { valid_jwt(id) }
      let(:not_user) { build(:user).id = 0 }

      before do
        get user_path(not_user), params: {}, headers: authorization_header(jwt)
      end

      it_behaves_like 'not_found response'
    end
  end

  # TODO: Move these to a shared when other actions add authorization
  context 'when no authorization' do
    subject(:request) { get user_path(user), params: {} }

    let(:user) { create(:user) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Nil JSON web token'
  end

  context 'when JWT has invalid encoding' do
    subject(:request) { get user_path(user), params: {}, headers: authorization_header(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_algorithm_jwt(user.id) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Expected a different algorithm'
  end

  context 'when JWT has invalid signature' do
    subject(:request) { get user_path(user), params: {}, headers: authorization_header(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_signature_jwt(user.id) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Signature verification failed'
  end

  context 'when JWT has invalid audience' do
    subject(:request) { get user_path(user), params: {}, headers: authorization_header(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_audience_jwt(user.id) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Invalid audience'
  end

  context 'when JWT has invalid issuer' do
    subject(:request) { get user_path(user), params: {}, headers: authorization_header(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { invalid_issuer_jwt(user.id) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Invalid issuer'
  end

  context 'when JWT has expired' do
    subject(:request) { get user_path(user), params: {}, headers: authorization_header(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { expired_jwt(user.id) }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Signature has expired'
  end

  context 'when JWT is misssing "user" claim' do
    subject(:request) { get user_path(user), params: {}, headers: authorization_header(jwt) }

    let(:user) { create(:user) }
    let(:jwt) { missing_user_claim_jwt }

    before do
      request
    end

    it_behaves_like 'unauthorized response', 'Missing required claim user'
  end
end
