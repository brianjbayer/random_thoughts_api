# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/shared_contexts/when_bad_request'
require_relative '../support/shared_examples/unprocessable_entity_schema'
RSpec.describe 'users' do
  path '/users' do
    post('create user') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user,
                in: :body,
                schema: { '$ref' => '#/components/schemas/new_user' }

      response(201, 'created') do
        let(:user) { build(:user) }
        schema '$ref' => '#/components/schemas/user'
        run_test!
      end

      response(400, 'bad request') do
        include_context 'when bad request'
        let(:user) { bad_request }
        run_test!
      end

      response(422, 'unprocessable entity') do
        # rubocop:disable Layout/LineLength
        msg = "Validation failed: Email can't be blank, Email must match URI::MailTo::EMAIL_REGEXP, Display name can't be blank"
        # rubocop:enable Layout/LineLength
        it_behaves_like 'unprocessable entity schema', msg
        example 'application/json', :email_exists, {
          status: 422,
          error: 'unprocessable_entity',
          message: 'Validation failed: Email has already been taken'
        }
        let(:empty_values) { build(:user, email: '', display_name: '') }
        let(:user) { empty_values }
        run_test!
      end
    end
  end
end
