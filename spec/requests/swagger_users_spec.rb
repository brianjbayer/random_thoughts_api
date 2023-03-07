# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/helpers/jwt_helper'
require_relative '../support/helpers/user_helper'
require_relative '../support/shared_examples/bad_request_schema'
require_relative '../support/shared_examples/not_found_schema'
require_relative '../support/shared_examples/unauthorized_schema'
require_relative '../support/shared_examples/unprocessable_entity_schema'

class UserMessage
  def self.not_found
    "Couldn't find User with 'id'=??"
  end
end

RSpec.describe 'users' do
  include UserHelper
  include JwtHelper

  # rubocop:disable RSpec/VariableName
  let(:Authorization) { "Bearer #{jwt}" }
  # rubocop:enable RSpec/VariableName

  path '/users' do
    post('create user') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user,
                in: :body,
                schema: { '$ref' => '#/components/schemas/create_user' }

      response(201, 'created') do
        let(:user) { build_user_body(build(:user)) }
        schema '$ref' => '#/components/schemas/same_user_response'
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

  path '/users/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show user') do
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      response(200, 'successful') do
        # NOTE: This is intended to test different users
        let(:jwt) { valid_jwt(create(:user)) }
        let(:id) { create(:user).id }

        schema oneOf: [{ '$ref' => '#/components/schemas/same_user_response' },
                       { '$ref' => '#/components/schemas/different_user_response' }]
        run_test!
      end

      response(401, 'unauthorized') do
        let(:user) { create(:user) }
        let(:id) { user.id }
        let(:jwt) { invalid_signature_jwt(user) }
        it_behaves_like 'unauthorized schema', 'Signature verification failed'
        run_test!
      end

      response(404, 'not found') do
        let(:jwt) { valid_jwt(create(:user)) }
        let(:id) { 0 }
        it_behaves_like 'not found schema', UserMessage.not_found
        run_test!
      end
    end

    delete('delete user') do
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      response(200, 'successful') do
        let(:user) { create(:user) }
        let(:jwt) { valid_jwt(user) }
        let(:id) { user.id }
        schema '$ref' => '#/components/schemas/same_user_response'
        run_test!
      end

      response(401, 'unauthorized') do
        let(:user) { create(:user) }
        let(:id) { user.id }
        let(:jwt) { invalid_algorithm_jwt(user) }
        it_behaves_like 'unauthorized schema', 'Expected a different algorithm'
        run_test!
      end

      response(404, 'not found') do
        let(:jwt) { valid_jwt(create(:user)) }
        let(:id) { 0 }
        it_behaves_like 'not found schema', UserMessage.not_found
        run_test!
      end
    end
  end
end
