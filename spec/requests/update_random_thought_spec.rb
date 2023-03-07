# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/random_thought_helper'
require_relative '../support/shared_examples/bad_request_response'
require_relative '../support/shared_examples/is_not_updated_from_request'
require_relative '../support/shared_examples/not_found_response'
require_relative '../support/shared_examples/unprocessable_entity_response'

RSpec.describe 'patch /random_thoughts/{id}' do
  include RandomThoughtHelper

  # Ensure the random_thought is created before updating it
  let!(:random_thought) { create(:random_thought) }
  let(:random_thought_update) { build(:random_thought) }
  let(:update) { build_random_thought_body(random_thought_update) }

  context 'when {id} exists' do
    context 'when valid update request' do
      it 'does not change the number of RandomThoughts' do
        expect do
          patch_random_thought(random_thought, update)
        end.not_to change(RandomThought, :count)
      end

      it 'updates thought when supplied' do
        just_thought = random_thought_update_just_keys(update, 'thought')
        patch_random_thought(random_thought, just_thought)
        expect(random_thought.reload.thought).to eql(random_thought_update.thought)
      end

      it 'updates name when supplied' do
        just_name = random_thought_update_just_keys(update, 'name')
        patch_random_thought(random_thought, just_name)
        expect(random_thought.reload.name).to eql(random_thought_update.name)
      end

      it 'returns "id": id' do
        patch_random_thought(random_thought, update)
        expect(json_body['id']).to eql(random_thought.id)
      end

      it 'returns updated random_thought JSON' do
        patch_random_thought(random_thought, update)
        expect(json_body).to be_random_thought_json(random_thought_update)
      end
    end

    context 'when update parameters are missing in update request' do
      let(:requesting) { random_thought }

      before do
        patch random_thought_path(requesting), params: empty_json_body
      end

      it_behaves_like 'is not updated from request', RandomThought
      it_behaves_like 'bad_request response'
    end

    context 'when validations fail for update request' do
      let(:requesting) { random_thought }

      before do
        empty_random_thought = build_random_thought_body(build(:random_thought, :empty))
        patch_random_thought(requesting, empty_random_thought)
      end

      it_behaves_like 'is not updated from request', RandomThought
      it_behaves_like 'unprocessable_entity response'
    end
  end

  context 'when {id} does not exist' do
    let(:does_not_exist) { build(:random_thought).id = 0 }

    before do
      patch_random_thought(does_not_exist, update)
    end

    it_behaves_like 'not_found response'
  end

  private

  def patch_random_thought(random_thought, update)
    patch random_thought_path(random_thought), params: update
  end

  def random_thought_update_just_keys(update, *keys)
    json_body_just_keys(:random_thought, update, *keys)
  end
end
