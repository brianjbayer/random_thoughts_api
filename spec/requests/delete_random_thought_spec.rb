# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/is_deleted_from_request'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/random_thought_response'

RSpec.describe 'delete /random_thoughts/{id}' do
  context 'when {id} exists' do
    let(:random_thought) { create(:random_thought) }
    # Ensure object to delete is created before expect block in 'is deleted...'
    # rubocop:disable RSpec/LetSetup
    let!(:object_to_delete) { random_thought }
    # rubocop:enable RSpec/LetSetup
    let(:delete_request) { delete_random_thought(random_thought) }

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
      delete_random_thought(does_not_exist)
    end

    it_behaves_like 'not_found response'
  end

  private

  def delete_random_thought(random_thought)
    delete random_thought_path(random_thought)
  end
end
