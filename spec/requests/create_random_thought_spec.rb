# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/bad_request_response'
require_relative '../support/shared_examples/random_thought_response'
require_relative '../support/shared_examples/unprocessable_entity_response'

RSpec.describe 'post /random_thoughts/' do
  shared_examples 'RandomThought not created' do
    it 'does not create a new RandomThought', :skip_before do
      expect do
        post_empty_request
      end.not_to change(RandomThought, :count)
    end
  end

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

    it_behaves_like 'RandomThought not created'

    it_behaves_like 'bad_request response'
  end

  # TODO: Testing invalid json does not seem to be possible

  context 'when validations fail for create request' do
    let(:not_valid) { build(:random_thought, thought: '', name: '') }

    before do |example|
      post_random_thought(not_valid) unless example.metadata[:skip_before]
    end

    it_behaves_like 'RandomThought not created'

    it_behaves_like 'unprocessable_entity response'
  end

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
