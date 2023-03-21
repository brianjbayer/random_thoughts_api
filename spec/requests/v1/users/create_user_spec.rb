# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../support/helpers/user_helper'
require_relative '../../../support/shared_examples/is_created_from_request'
require_relative '../../../support/shared_examples/is_not_created_from_request'
require_relative '../../../support/shared_examples/same_user_response'
require_relative '../../../support/shared_examples/errors/bad_request_response'
require_relative '../../../support/shared_examples/errors/unprocessable_entity_response'

RSpec.describe 'post /v1/users/' do
  include UserHelper

  context 'when valid create request for a new user' do
    subject(:request) { post_user(user) }

    let(:user) { build(:user) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is created from request', User

    it_behaves_like 'same user response'
  end

  context 'when parameters are missing in create request' do
    subject(:request) { raw_post_user(empty_json_body) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not created from request', User

    it_behaves_like 'bad_request response'
  end

  context 'when user already exists' do
    subject(:request) { post_user(duplicate_user) }

    let!(:existing_user) { create(:user) }
    let(:duplicate_user) { build(:user, email: existing_user.email) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it 'returns "message": indicating user already exists' do
      expect(json_body['message']).to include('Email has already been taken')
    end

    it_behaves_like 'is not created from request', User

    it_behaves_like 'unprocessable_entity response'
  end

  context 'when validations fail for create request' do
    subject(:request) { post_user(not_valid) }

    let(:not_valid) { build(:user, :empty) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is not created from request', User

    it_behaves_like 'unprocessable_entity response'
  end

  private

  def post_user(user)
    raw_post_user(build_user_body(user))
  end

  def raw_post_user(params)
    post v1_users_path, params:
  end
end
