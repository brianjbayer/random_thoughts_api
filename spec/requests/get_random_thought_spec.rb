# frozen_string_literal: true

require 'rails_helper'
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

  context 'when {id} does not exists' do
    let(:not_random_thought) { build(:random_thought).id = 0 }

    before do
      get random_thought_path(not_random_thought)
    end

    it 'returns "status": 404' do
      expect(json_body['status']).to be(404)
    end

    it 'returns "error": "not_found"' do
      expect(json_body['error']).to eql('not_found')
    end

    it 'returns "message": ...' do
      expect(json_body['message']).to include("Couldn't find ")
    end
  end
end
