# frozen_string_literal: true

require 'swagger_helper'
require_relative '../support/random_thought_helper'
require_relative '../support/shared_contexts/when_bad_request'
require_relative '../support/shared_examples/unprocessable_entity_schema'

RSpec.describe 'random_thoughts' do
  include RandomThoughtHelper

  shared_context 'when not found' do
    let(:id) { 0 }
    schema '$ref' => '#/components/schemas/error'
    example 'application/json', :not_found, {
      status: 404,
      error: 'not_found',
      message: "Couldn't find RandomThought with 'id'=??"
    }
  end

  path '/random_thoughts' do
    get('list random_thoughts') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'page',
                in: :query,
                type: :integer,
                description: 'page number',
                required: false

      response(200, 'successful') do
        # rubocop:disable RSpec/LetSetup
        let!(:random_thought) { create(:random_thought) }
        # rubocop:enable RSpec/LetSetup
        schema '$ref' => '#/components/schemas/paginated_random_thoughts'
        run_test!
      end
    end

    post('create random_thought') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :random_thought,
                in: :body,
                schema: { '$ref' => '#/components/schemas/create_random_thought' }

      response(201, 'created') do
        let(:random_thought) { build_random_thought_body(build(:random_thought)) }
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(400, 'bad request') do
        include_context 'when bad request'
        let(:random_thought) { bad_request }
        run_test!
      end

      response(422, 'unprocessable entity') do
        msg = "Validation failed: Thought can't be blank, Name can't be blank"
        it_behaves_like 'unprocessable entity schema', msg
        let(:empty_values) { build_random_thought_body(build(:random_thought, :empty)) }
        let(:random_thought) { empty_values }
        run_test!
      end
    end
  end

  path '/random_thoughts/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    get('show random_thought') do
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { create(:random_thought).id }
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(404, 'not found') do
        include_context 'when not found'
        run_test!
      end
    end

    patch('update random_thought') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :update,
                in: :body,
                schema: { '$ref' => '#/components/schemas/update_random_thought' }

      response(200, 'successful') do
        let(:id) { create(:random_thought).id }
        let(:update) { build_random_thought_body(build(:random_thought)) }
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(400, 'bad request') do
        include_context 'when bad request'
        let(:id) { create(:random_thought).id }
        let(:update) { bad_request }
        run_test!
      end

      response(404, 'not found') do
        include_context 'when not found'
        let(:update) { build_random_thought_body(build(:random_thought)) }
        run_test!
      end

      response(422, 'unprocessable entity') do
        msg = "Validation failed: Thought can't be blank, Name can't be blank"
        it_behaves_like 'unprocessable entity schema', msg
        let(:id) { create(:random_thought).id }
        let(:empty_values) { build_random_thought_body(build(:random_thought, :empty)) }
        let(:update) { empty_values }
        run_test!
      end
    end

    delete('delete random_thought') do
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { create(:random_thought).id }
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(404, 'not found') do
        include_context 'when not found'
        run_test!
      end
    end
  end
end
