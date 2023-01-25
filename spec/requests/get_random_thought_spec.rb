# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'get /random_thoughts/{id}' do
  context 'when {id} exists' do
    let(:random_thought) { create(:random_thought) }

    before do
      get random_thought_path(random_thought)
    end

    it 'returns "id": id' do
      expect(json_body['id']).to eql(random_thought.id)
    end

    it 'returns "thought": thought' do
      expect(json_body['thought']).to eql(random_thought.thought)
    end

    it 'returns "name": name' do
      expect(json_body['name']).to eql(random_thought.name)
    end
  end

  def json_body
    JSON.parse(response.body)
  end
end
