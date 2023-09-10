# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../support/helpers/jwt_helper'
require_relative '../../../support/helpers/random_thought_helper'
require_relative '../../../support/shared_examples/is_not_updated_from_request'
require_relative '../../../support/shared_examples/jwt_authorization'
require_relative '../../../support/shared_examples/errors/bad_request_response'
require_relative '../../../support/shared_examples/errors/not_found_response'
require_relative '../../../support/shared_examples/errors/unprocessable_entity_response'

RSpec.describe 'patch /v1/random_thoughts/{id}' do
  include JwtHelper
  include RandomThoughtHelper

  let!(:user) { create(:user) }
  let(:valid_auth_jwt) { valid_jwt(user) }
  # Ensure the random_thought is created before updating it
  # and associate it with the user
  let!(:random_thought) { create(:random_thought, user:) }
  let(:random_thought_update) { build(:random_thought) }
  let(:update) { build_random_thought_body(random_thought_update) }

  describe 'authorization' do
    let(:request_without_jwt) { raw_patch_random_thought(random_thought, update) }
    let(:request_with_jwt) { patch_random_thought(random_thought, jwt, update) }

    it_behaves_like 'jwt_authorization'
  end

  context "when {id} is current user's id" do
    context 'when valid update request' do
      it 'does not change the number of RandomThoughts' do
        expect do
          patch_random_thought(random_thought, valid_auth_jwt, update)
        end.not_to change(RandomThought, :count)
      end

      it 'updates thought when supplied' do
        just_thought = random_thought_update_just_keys(update, 'thought')
        patch_random_thought(random_thought, valid_auth_jwt, just_thought)
        expect(random_thought.reload.thought).to eql(random_thought_update.thought)
      end

      it 'updates mood when supplied' do
        just_mood = random_thought_update_just_keys(update, 'mood')
        patch_random_thought(random_thought, valid_auth_jwt, just_mood)
        expect(random_thought.reload.mood).to eql(random_thought_update.mood)
      end

      it 'returns "id": id' do
        patch_random_thought(random_thought, valid_auth_jwt, update)
        expect(json_body['id']).to eql(random_thought.id)
      end

      it 'returns updated random_thought JSON' do
        patch_random_thought(random_thought, valid_auth_jwt, update)
        expect(json_body).to be_random_thought_json(random_thought_update, random_thought.user)
      end
    end

    context "when {id} is different user's id" do
      let!(:requesting) { create(:random_thought, user: create(:user)) }
      let(:update_request) { patch_random_thought(requesting, valid_auth_jwt, update) }

      before do
        update_request
      end

      it_behaves_like 'is not updated from request', RandomThought

      it_behaves_like 'unauthorized response', 'Unauthorized: User does not have authorization for this action'
    end

    context 'when update parameters are missing in update request' do
      let(:requesting) { random_thought }

      before do
        raw_patch_random_thought(requesting, empty_json_body, headers: authorization_header(valid_auth_jwt))
      end

      it_behaves_like 'is not updated from request', RandomThought
      it_behaves_like 'bad_request response'
    end

    context 'when validations fail for update request' do
      let(:requesting) { random_thought }

      before do
        empty_random_thought = build_random_thought_body(build(:random_thought, :empty))
        patch_random_thought(requesting, valid_auth_jwt, empty_random_thought)
      end

      it_behaves_like 'is not updated from request', RandomThought
      it_behaves_like 'unprocessable_entity response'
    end
  end

  context 'when {id} does not exist' do
    let(:does_not_exist) { build(:random_thought).id = 0 }

    before do
      patch_random_thought(does_not_exist, valid_auth_jwt, update)
    end

    it_behaves_like 'not_found response'
  end

  private

  def patch_random_thought(random_thought, jwt, update)
    raw_patch_random_thought(random_thought, update, headers: authorization_header(jwt))
  end

  def raw_patch_random_thought(random_thought, params, headers: false)
    if headers
      patch v1_random_thought_path(random_thought), params:, headers:
    else
      patch v1_random_thought_path(random_thought), params:
    end
  end

  def random_thought_update_just_keys(update, *)
    json_body_just_keys(:random_thought, update, *)
  end
end
