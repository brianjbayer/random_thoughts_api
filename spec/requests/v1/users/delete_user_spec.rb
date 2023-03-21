# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../support/helpers/jwt_helper'
require_relative '../../../support/shared_examples/is_deleted_from_request'
require_relative '../../../support/shared_examples/is_not_deleted_from_request'
require_relative '../../../support/shared_examples/jwt_authorization'
require_relative '../../../support/shared_examples/same_user_response'
require_relative '../../../support/shared_examples/errors/not_found_response'

RSpec.describe 'delete /users/{id}' do
  include JwtHelper

  let(:user) { create(:user) }

  describe 'authorization' do
    let(:request_without_jwt) { raw_delete_user(user) }
    let(:request_with_jwt) { delete_user(user, jwt) }

    it_behaves_like 'jwt_authorization'
  end

  context 'when valid authorization' do
    let(:valid_auth_jwt) { valid_jwt(user) }

    context "when {id} is current user's id" do
      # Ensure object to delete is created before expect block in 'is deleted...'
      # rubocop:disable RSpec/LetSetup
      let!(:object_to_delete) { user }
      # rubocop:enable RSpec/LetSetup
      let(:delete_request) { delete_user(user, valid_auth_jwt) }

      before do |example|
        delete_request unless example.metadata[:skip_before]
      end

      it_behaves_like 'is deleted from request', User

      it 'returns "id": id' do
        expect(json_body['id']).to eql(user.id)
      end

      it_behaves_like 'same user response'
    end

    context "when {id} is different user's id" do
      # Ensure objects are created before expect block in 'is not deleted...'
      # rubocop:disable RSpec/LetSetup
      let!(:requesting_user) { user }
      # rubocop:enable RSpec/LetSetup
      let!(:requested_user) { create(:user) }
      let(:delete_request) { delete_user(requested_user, valid_auth_jwt) }

      before do |example|
        delete_request unless example.metadata[:skip_before]
      end

      it_behaves_like 'is not deleted from request', User

      it_behaves_like 'unauthorized response', 'Unauthorized: User does not have authorization for this action'
    end

    context 'when {id} does not exist' do
      let(:does_not_exist) { build(:user).id = 0 }

      before do
        delete_user(does_not_exist, valid_auth_jwt)
      end

      it_behaves_like 'not_found response'
    end
  end

  private

  def delete_user(user, jwt)
    raw_delete_user(user, headers: authorization_header(jwt))
  end

  def raw_delete_user(user, headers: false)
    if headers
      delete v1_user_path(user), headers:
    else
      delete v1_user_path(user)
    end
  end
end
