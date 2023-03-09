# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/shared_examples/jwt_authorization'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/same_user_response'

RSpec.describe 'get /user/{id}' do
  include JwtHelper

  let(:user) { create(:user) }

  describe 'authorization' do
    let(:request_without_jwt) { get user_path(user), params: {} }
    let(:request_with_jwt) { get_user(user, jwt) }

    it_behaves_like 'jwt_authorization'
  end

  context 'when valid authorization' do
    let(:valid_auth_jwt) { valid_jwt(user) }

    context "when {id} is current user's id" do
      before do
        get_user(user, valid_auth_jwt)
      end

      it_behaves_like 'same user response'
    end

    context "when {id} is different user's id" do
      let(:different_user) { create(:user) }

      before do
        get_user(different_user, valid_auth_jwt)
      end

      it 'returns different user JSON with correct values' do
        expect(json_body).to be_different_user_json(different_user)
      end
    end

    context 'when {id} does not exist' do
      let(:not_user) { build(:user).id = 0 }

      before do
        get_user(not_user, valid_auth_jwt)
      end

      it_behaves_like 'not_found response'
    end
  end

  private

  def get_user(user, jwt)
    get user_path(user), headers: authorization_header(jwt)
  end
end
