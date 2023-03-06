# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/helpers/random_thought_helper'
require_relative '../support/shared_examples/bad_request_response'
require_relative '../support/shared_examples/is_created_from_request'
require_relative '../support/shared_examples/is_not_created_from_request'
require_relative '../support/shared_examples/random_thought_response'
require_relative '../support/shared_examples/unprocessable_entity_response'

RSpec.describe 'post /random_thoughts/' do
  include RandomThoughtHelper

  context 'when valid create request' do
    subject(:request) { post_random_thought(random_thought) }

    let(:random_thought) { build(:random_thought) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is created from request', RandomThought

    it_behaves_like 'random thought response'
  end

  context 'when parameters are missing in create request' do
    subject(:request) { post random_thoughts_path, params: empty_json_body }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not created from request', RandomThought

    it_behaves_like 'bad_request response'
  end

  # TODO: Testing invalid json does not seem to be possible

  context 'when validations fail for create request' do
    subject(:request) { post_random_thought(not_valid) }

    let(:not_valid) { build(:random_thought, :empty) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not created from request', RandomThought

    it_behaves_like 'unprocessable_entity response'
  end

  private

  def post_random_thought(random_thought)
    post random_thoughts_path, params: build_random_thought_body(random_thought)
  end
end
