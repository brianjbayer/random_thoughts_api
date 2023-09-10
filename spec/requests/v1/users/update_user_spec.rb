# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../support/helpers/jwt_helper'
require_relative '../../../support/helpers/user_helper'
require_relative '../../../support/shared_examples/is_not_updated_from_request'
require_relative '../../../support/shared_examples/jwt_authorization'
require_relative '../../../support/shared_examples/same_user_response'
require_relative '../../../support/shared_examples/errors/bad_request_response'
require_relative '../../../support/shared_examples/errors/not_found_response'
require_relative '../../../support/shared_examples/errors/unprocessable_entity_response'

RSpec.describe 'patch /v1/users/{id}' do
  include JwtHelper
  include UserHelper

  # Ensure the user is created before updating it
  let!(:user) { create(:user) }
  let(:user_update) { build(:user) }
  let(:update) { build_user_body(user_update) }
  let(:valid_auth_jwt) { valid_jwt(user) }

  describe 'authorization' do
    let(:request_without_jwt) { raw_patch_user(user, update) }
    let(:request_with_jwt) { patch_user(user, jwt, update) }

    it_behaves_like 'jwt_authorization'
  end

  context 'when valid update request' do
    context "when {id} is current user's id" do
      it 'does not change the number of Users' do
        expect do
          patch_user(user, valid_auth_jwt, update)
        end.not_to change(User, :count)
      end

      it 'updates email when supplied' do
        just_email = user_update_just_keys(update, 'email')
        patch_user(user, valid_auth_jwt, just_email)
        expect(user.reload.email).to eql(user_update.email)
      end

      it 'updates display_name when supplied' do
        just_display_name = user_update_just_keys(update, 'display_name')
        patch_user(user, valid_auth_jwt, just_display_name)
        expect(user.reload.display_name).to eql(user_update.display_name)
      end

      it 'updates password when supplied' do
        just_password = user_update_just_keys(update, 'password', 'password_confirmation')
        patch_user(user, valid_auth_jwt, just_password)
        expect(user.reload.authenticate(user_update.password)).to eql(user)
      end

      it 'returns "id": id' do
        patch_user(user, valid_auth_jwt, update)
        expect(json_body['id']).to eql(user.id)
      end

      it 'returns updated same user JSON' do
        patch_user(user, valid_auth_jwt, update)
        expect(json_body).to be_same_user_json(user_update)
      end
    end

    context "when {id} is different user's id" do
      let(:requesting) { user }
      let!(:requested) { create(:user) }

      before do
        patch_user(requested, valid_auth_jwt, update)
      end

      it_behaves_like 'is not updated from request', User
      it_behaves_like 'unauthorized response', 'Unauthorized: User does not have authorization for this action'
    end
  end

  context 'when update parameters are missing in update request' do
    let(:requesting) { user }

    before do
      raw_patch_user(requesting, empty_json_body, headers: authorization_header(valid_auth_jwt))
    end

    it_behaves_like 'is not updated from request', User
    it_behaves_like 'bad_request response'
  end

  context 'when validations fail for update request' do
    let(:requesting) { user }

    before do
      patch_user(requesting, valid_auth_jwt, build_user_body(build(:user, :empty)))
    end

    it_behaves_like 'is not updated from request', User
    it_behaves_like 'unprocessable_entity response'
  end

  context 'when {id} does not exist' do
    let(:does_not_exist) { build(:user).id = 0 }

    before do
      patch_user(does_not_exist, valid_auth_jwt, update)
    end

    it_behaves_like 'not_found response'
  end

  private

  def patch_user(user, jwt, update)
    raw_patch_user(user, update, headers: authorization_header(jwt))
  end

  def raw_patch_user(user, params, headers: false)
    if headers
      patch v1_user_path(user), params:, headers:
    else
      patch v1_user_path(user), params:
    end
  end

  def user_update_just_keys(update, *)
    json_body_just_keys(:user, update, *)
  end
end
