# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/helpers/random_thought_helper'
require_relative '../support/shared_examples/bad_request_response'
require_relative '../support/shared_examples/is_created_from_request'
require_relative '../support/shared_examples/is_not_created_from_request'
require_relative '../support/shared_examples/jwt_authorization'
require_relative '../support/shared_examples/random_thought_response'
require_relative '../support/shared_examples/unprocessable_entity_response'

RSpec.describe 'post /random_thoughts/' do
  include JwtHelper
  include RandomThoughtHelper

  let!(:user) { create(:user) }
  let(:valid_auth_jwt) { valid_jwt(user) }
  let(:random_thought) { build(:random_thought) }

  describe 'authorization' do
    let(:request_without_jwt) { raw_post_random_thought(build_random_thought_body(random_thought)) }
    let(:request_with_jwt) { post_random_thought(random_thought, jwt) }

    it_behaves_like 'jwt_authorization'
  end

  context 'when valid create request' do
    subject(:request) { post_random_thought(random_thought, valid_auth_jwt) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is created from request', RandomThought

    it_behaves_like 'random thought response'
  end

  context 'when parameters are missing in create request' do
    subject(:request) { raw_post_random_thought(empty_json_body, headers: authorization_header(valid_auth_jwt)) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not created from request', RandomThought

    it_behaves_like 'bad_request response'
  end

  # TODO: Testing invalid json does not seem to be possible

  context 'when validations fail for create request' do
    subject(:request) { post_random_thought(not_valid, valid_auth_jwt) }

    let(:not_valid) { build(:random_thought, :empty) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not created from request', RandomThought

    it_behaves_like 'unprocessable_entity response'
  end

  private

  def post_random_thought(random_thought, jwt)
    raw_post_random_thought(build_random_thought_body(random_thought), headers: authorization_header(jwt))
  end

  def raw_post_random_thought(params, headers: false)
    if headers
      post random_thoughts_path, params:, headers:
    else
      post random_thoughts_path, params:
    end
  end
end
