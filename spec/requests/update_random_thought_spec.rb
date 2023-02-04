# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/not_found_response'

RSpec.describe 'patch /random_thoughts/{id}' do
  context 'when {id} exists' do
    let!(:random_thought) { create(:random_thought) }
    let(:new_thought) { 'I like turtles' }
    let(:new_name) { 'Jonathan "Zombie Kid" Ware' }

    it 'does not change the number of RandomThoughts' do
      expect do
        patch_random_thought(random_thought, new_thought:, new_name:)
      end.not_to change(RandomThought, :count)
    end

    it 'updates thought when supplied' do
      patch_random_thought(random_thought, new_thought:)
      expect(random_thought.reload.thought).to eql(new_thought)
    end

    it 'updates name when supplied' do
      patch_random_thought(random_thought, new_name:)
      expect(random_thought.reload.name).to eql(new_name)
    end

    it 'returns "id": id' do
      patch_random_thought(random_thought, new_thought:, new_name:)
      expect(json_body['id']).to eql(random_thought.id)
    end

    it 'returns updated random_thought JSON' do
      patch_random_thought(random_thought, new_thought:, new_name:)
      expect(json_body).to be_random_thought_json(random_thought.reload)
    end
  end

  context 'when {id} does not exist' do
    let(:does_not_exist) { build(:random_thought).id = 0 }

    before do
      patch_random_thought(does_not_exist, new_thought: '...', new_name: '...')
    end

    it_behaves_like 'not_found response'
  end

  private

  def patch_random_thought(random_thought, new_thought: false, new_name: false)
    update = {}
    update['thought'] = new_thought if new_thought
    update['name'] = new_name if new_name
    patch random_thought_path(random_thought), params: update, as: :json
  end
end
