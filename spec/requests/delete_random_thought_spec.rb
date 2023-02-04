# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/random_thought_response'

RSpec.describe 'delete /random_thoughts/{id}' do
  context 'when {id} exists' do
    let!(:random_thought) { create(:random_thought) }

    before do |example|
      delete_random_thought(random_thought) unless example.metadata[:skip_before]
    end

    it 'deletes a RandomThought', :skip_before do
      expect do
        delete_random_thought(random_thought)
      end.to change(RandomThought, :count).by(-1)
    end

    it 'deletes the random thought' do
      expect(RandomThought.find_by(id: random_thought.id)).to be_nil
    end

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
