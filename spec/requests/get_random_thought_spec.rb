# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/random_thought_response'

RSpec.describe 'get /random_thoughts/{id}' do
  context 'when {id} exists' do
    let(:random_thought) { create(:random_thought) }

    before do
      get random_thought_path(random_thought)
    end

    it 'returns "id": id' do
      expect(json_body['id']).to eql(random_thought.id)
    end

    it_behaves_like 'random thought response'
  end

  context 'when {id} does not exist' do
    let(:not_random_thought) { build(:random_thought).id = 0 }

    before do
      get random_thought_path(not_random_thought)
    end

    it_behaves_like 'not_found response'
  end
end
