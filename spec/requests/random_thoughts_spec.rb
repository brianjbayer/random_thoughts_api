# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'random_thoughts', type: :request do

  # path '/random_thoughts' do

    # get('list random_thoughts') do
    #   response(200, 'successful') do

    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end

  #   post('create random_thought') do
  #     response(200, 'successful') do

  #       after do |example|
  #         example.metadata[:response][:content] = {
  #           'application/json' => {
  #             example: JSON.parse(response.body, symbolize_names: true)
  #           }
  #         }
  #       end
  #       run_test!
  #     end
  #   end
  # end

  path '/random_thoughts/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show random_thought') do
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { create(:random_thought).id }
        schema '$ref' => '#/components/schemas/random_thought'

        after do |example|
          example.metadata[:response][:content] = {
            'application/json' => {
              example: JSON.parse(response.body, symbolize_names: true)
            }
          }
        end

        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        schema '$ref' => '#/components/schemas/error'
        example 'application/json', :not_found, {
          status: 404,
          error: 'not_found',
          message: "Couldn't find RandomThought with 'id'=??"
        }

        run_test!
      end

      # THIS TEST IS SKIPPED
      # Unable to produce the test conditions for 500
      response(500, 'internal server error') do
        let(:id) { create(:random_thought).id }
        schema '$ref' => '#/components/schemas/error'
        example 'application/json', :internal_server_error, {
          status: 500,
          error: 'internal_server_error',
          message: '...'
        }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns a 500 response' do |example|
          # SKIP !!!
          skip
          assert_response_matches_metadata(example.metadata)
        end
      end
    end

    # patch('update random_thought') do
    #   response(200, 'successful') do
    #     let(:id) { '123' }

    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end

    # put('update random_thought') do
    #   response(200, 'successful') do
    #     let(:id) { '123' }

    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end

    # delete('delete random_thought') do
    #   response(200, 'successful') do
    #     let(:id) { '123' }

    #     after do |example|
    #       example.metadata[:response][:content] = {
    #         'application/json' => {
    #           example: JSON.parse(response.body, symbolize_names: true)
    #         }
    #       }
    #     end
    #     run_test!
    #   end
    # end
  end
end
