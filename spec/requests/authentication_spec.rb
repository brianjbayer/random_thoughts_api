# frozen_string_literal: true

require 'swagger_helper'

require_relative '../support/helpers/login_helper'
require_relative '../support/shared_examples/bad_request_schema'

RSpec.describe 'authentications' do
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
          status: 200,
          message: 'User logged in successfully',
          token: 'xxxxxxxx.xxxxxxxxxx.xxxxxx'
        }
        run_test!
      end

      response(401, 'unauthorized') do
        # FYI: Totally empty, missing credentials, bad credentials all end up here
        let(:login) { empty_json_body }
        schema '$ref' => '#/components/schemas/error'
        example 'application/json', :unauthorized, {
          status: 401,
          error: 'unauthorized',
          message: 'Invalid login'
        }
        run_test!
      end
    end
  end
end
