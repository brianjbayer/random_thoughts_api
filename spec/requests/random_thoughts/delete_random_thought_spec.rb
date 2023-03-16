# frozen_string_literal: true

require 'rails_helper'

require_relative '../../support/helpers/jwt_helper'
require_relative '../../support/shared_examples/is_deleted_from_request'
require_relative '../../support/shared_examples/is_not_deleted_from_request'
require_relative '../../support/shared_examples/jwt_authorization'
require_relative '../../support/shared_examples/random_thought_response'
require_relative '../../support/shared_examples/errors/not_found_response'

# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe 'delete /random_thoughts/{id}' do
  include JwtHelper

  # Ensure user is created before authorization
  let!(:user) { create(:user) }
  let(:valid_auth_jwt) { valid_jwt(user) }
  # RandomThought is created before authorization
  # and associate it with the user
  let!(:random_thought) { create(:random_thought, user:) }

  describe 'authorization' do
    let(:request_without_jwt) { delete random_thought_path(random_thought) }
    let(:request_with_jwt) { delete_random_thought(random_thought, jwt) }

    it_behaves_like 'jwt_authorization'
  end

  context "when {id} is current user's id" do
    # Ensure object to delete is created before expect block in 'is deleted...'
    # rubocop:disable RSpec/LetSetup
    let!(:object_to_delete) { random_thought }
    # rubocop:enable RSpec/LetSetup
    let(:delete_request) { delete_random_thought(random_thought, valid_auth_jwt) }

    before do |example|
      delete_request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is deleted from request', RandomThought

    it 'returns "id": id' do
      expect(json_body['id']).to eql(random_thought.id)
    end

    it_behaves_like 'random thought response'
  end

  context "when {id} is different user's id" do
    # Ensure objects are created before expect block in 'is not deleted...'
    # rubocop:disable RSpec/LetSetup
    let!(:requesting_user) { user }
    # rubocop:enable RSpec/LetSetup
    let!(:other_user_random_thought) { create(:random_thought, user: create(:user)) }

    let(:delete_request) { delete_random_thought(other_user_random_thought, valid_auth_jwt) }

    before do |example|
      delete_request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not deleted from request', RandomThought

    it_behaves_like 'unauthorized response', 'Unauthorized: User does not have authorization for this action'
  end

  context 'when {id} does not exist' do
    let(:does_not_exist) { build(:random_thought).id = 0 }

    before do
      delete_random_thought(does_not_exist, valid_auth_jwt)
    end

    it_behaves_like 'not_found response'
  end

  private

  def delete_random_thought(random_thought, jwt)
    delete random_thought_path(random_thought), headers: authorization_header(jwt)
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
