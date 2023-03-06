# frozen_string_literal: true

require 'swagger_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/helpers/login_helper'
require_relative '../support/shared_examples/bad_request_schema'
require_relative '../support/shared_examples/unauthorized_schema'

RSpec.describe 'authentications' do
  include JwtHelper
  include LoginHelper

  path '/login' do
    post('login') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :login,
                in: :body,
                schema: { '$ref' => '#/components/schemas/login' }

      response(200, 'logged in') do
        let(:login) { build_login_body(create(:user)) }
        schema '$ref' => '#/components/schemas/login_response'
        example 'application/json', :successful_login, {
          message: 'User logged in successfully',
          token: 'xxxxxxxx.xxxxxxxxxx.xxxxxx'
        }
        run_test!
      end

      response(401, 'unauthorized') do
        # FYI: Totally empty, missing credentials, bad credentials all end up here
        let(:login) { empty_json_body }
        it_behaves_like 'unauthorized schema', 'Invalid login'
        run_test!
      end
    end
  end

  path '/logout' do
    get('logout') do
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      response(200, 'logged out') do
        # rubocop:disable RSpec/VariableName
        let(:Authorization) { "Bearer #{jwt}" }
        # rubocop:enable RSpec/VariableName
        let(:jwt) { valid_jwt(create(:user)) }

        schema '$ref' => '#/components/schemas/logout_response'
        example 'application/json', :successful_logout, {
          message: 'User logged out successfully'
        }
        run_test!
      end

      response(401, 'unauthorized') do
        # rubocop:disable RSpec/VariableName
        let(:Authorization) { '' }
        # rubocop:enable RSpec/VariableName
        it_behaves_like 'unauthorized schema', 'Nil JSON web token'
        run_test!
      end
    end
  end
end
