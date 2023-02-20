# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/helpers/user_helper'
require_relative '../support/shared_examples/bad_request_schema'
require_relative '../support/shared_examples/unprocessable_entity_schema'

RSpec.describe 'users' do
  include UserHelper

  path '/users' do
    post('create user') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user,
                in: :body,
                schema: { '$ref' => '#/components/schemas/create_user' }

      response(201, 'created') do
        let(:user) { build_user_body(build(:user)) }
        schema '$ref' => '#/components/schemas/user_response'
        run_test!
      end

      response(400, 'bad request') do
        let(:user) { empty_json_body }
        it_behaves_like 'bad request schema'
        run_test!
      end

      response(422, 'unprocessable entity') do
        msg = 'Validation failed: ' \
              "Email can't be blank, Email must match URI::MailTo::EMAIL_REGEXP, " \
              "Display name can't be blank, " \
              "Password can't be blank, Password is too short (minimum is 8 characters)"
        it_behaves_like 'unprocessable entity schema', msg
        example 'application/json', :email_exists, {
          status: 422,
          error: 'unprocessable_entity',
          message: 'Validation failed: Email has already been taken'
        }
        let(:empty_values) { build(:user, :empty) }
        let(:user) { empty_values }
        run_test!
      end
    end
  end
end
