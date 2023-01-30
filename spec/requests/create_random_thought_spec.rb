# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/random_thought_response'

RSpec.describe 'post /random_thoughts/' do
  context 'when valid create request' do
    let(:random_thought) { build(:random_thought) }

    before do |example|
      post_random_thought(random_thought) unless example.metadata[:skip_before]
    end

    it 'creates a new RandomThought', :skip_before do
      expect do
        post_random_thought(random_thought)
      end.to change(RandomThought, :count).by(1)
    end

    it_behaves_like 'random thought response'
  end

  context 'when parameters are missing in create request' do
    before do |example|
      post_empty_request unless example.metadata[:skip_before]
    end

    it 'does not create a new RandomThought', :skip_before do
      expect do
        post_empty_request
      end.not_to change(RandomThought, :count)
    end

    it 'returns "status": 400' do
      expect(json_body['status']).to be(400)
    end

    it 'returns "error": "bad_request"' do
      expect(json_body['error']).to eql('bad_request')
    end

    it 'returns "message" indicating parameters are missing' do
      expect(json_body['message']).to include('param is missing or the value is empty')
    end
  end

  # TODO: Testing invalid json does not seem to be possible

  private

  def post_random_thought(random_thought)
    post random_thoughts_path, params: {
      random_thought: {
        thought: random_thought.thought,
        name: random_thought.name
      }
    }
  end

  def post_empty_request
    post random_thoughts_path, params: {}
  end
end
