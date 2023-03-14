# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/shared_examples/is_deleted_from_request'
require_relative '../support/shared_examples/jwt_authorization'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/random_thought_response'

RSpec.describe 'delete /random_thoughts/{id}' do
  include JwtHelper

  let(:user) { create(:user) }
  let(:valid_auth_jwt) { valid_jwt(user) }
  let(:random_thought) { create(:random_thought) }

  describe 'authorization' do
    let(:request_without_jwt) { delete random_thought_path(random_thought) }
    let(:request_with_jwt) { delete_random_thought(random_thought, jwt) }

    it_behaves_like 'jwt_authorization'
  end

  context 'when {id} exists' do
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
