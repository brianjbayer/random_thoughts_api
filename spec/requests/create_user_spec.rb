# frozen_string_literal: true

require 'rails_helper'
require_relative '../support/shared_examples/bad_request_response'
require_relative '../support/shared_examples/is_created_from_request'
require_relative '../support/shared_examples/not_created_from_request'
require_relative '../support/shared_examples/unprocessable_entity_response'

RSpec.describe 'post /users/' do
  context 'when valid create request for a new user' do
    subject(:request) { post_user(new_user) }

    let(:new_user) { build(:user) }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'is created from request', User

    # TODO: it_behaves_like 'user response'
    it 'returns "email": email' do
      expect(json_body['email']).to eql(new_user.email)
    end

    it 'returns "display_name": display_name' do
      expect(json_body['display_name']).to eql(new_user.display_name)
    end
  end

  context 'when parameters are missing in create request' do
    subject(:request) { post users_path, params: {} }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'not created from request', User

    it_behaves_like 'bad_request response'
  end

  # TODO: Testing invalid json does not seem to be possible

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

    it_behaves_like 'not created from request', User

    it_behaves_like 'unprocessable_entity response'
  end

  context 'when validations fail for create request' do
    subject(:request) { post_user(not_valid) }

    let(:not_valid) { build(:user, email: '', display_name: '') }

    before do |example|
      request unless example.metadata[:skip_before]
    end

    it_behaves_like 'not created from request', User

    it_behaves_like 'unprocessable_entity response'
  end

  private

  def post_user(user)
    post users_path, params: {
      user: {
        email: user.email,
        display_name: user.display_name
      }
    }
  end
end
