# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'random_thoughts' do
  shared_context 'when not found' do
    let(:id) { 0 }
    schema '$ref' => '#/components/schemas/error'
    example 'application/json', :not_found, {
      status: 404,
      error: 'not_found',
      message: "Couldn't find RandomThought with 'id'=??"
    }
  end

  shared_context 'when unprocessable entity' do
    let(:empty_values) { build(:random_thought, thought: '', name: '') }
    schema '$ref' => '#/components/schemas/error'
    example 'application/json', :unprocessable_entity, {
      status: 422,
      error: 'unprocessable_entity',
      message: "Validation failed: Thought can't be blank, Name can't be blank"
    }
  end

  shared_context 'when bad request' do
    let(:bad_request) { {} }
    schema '$ref' => '#/components/schemas/error'
    example 'application/json', :empty_request, {
      status: 400,
      error: 'bad_request',
      message: 'param is missing or the value is empty:...'
    }
    example 'application/json', :invalid_request, {
      status: 400,
      error: 'bad_request',
      message: 'Error occurred while parsing request parameters'
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
        let!(:random_thought) { create(:random_thought) }
        schema '$ref' => '#/components/schemas/paginated_random_thoughts'
        run_test!
      end
    end

    post('create random_thought') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: :random_thought,
                in: :body,
                schema: { '$ref' => '#/components/schemas/new_random_thought' }

      response(201, 'created') do
        let(:random_thought) { build(:random_thought) }
        schema '$ref' => '#/components/schemas/random_thought'
        run_test!
      end

      response(400, 'bad request') do
        include_context 'when bad request'
        let(:random_thought) { bad_request }
        run_test!
      end

      response(422, 'unprocessable entity') do
        include_context 'when unprocessable entity'
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
        schema '$ref' => '#/components/schemas/random_thought'
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
        let(:update) { build(:random_thought) }
        schema '$ref' => '#/components/schemas/random_thought'
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
        let(:update) { build(:random_thought) }
        run_test!
      end

      response(422, 'unprocessable entity') do
        include_context 'when unprocessable entity'
        let(:id) { create(:random_thought).id }
        let(:update) { empty_values }
        run_test!
      end
    end

    delete('delete random_thought') do
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        let(:id) { create(:random_thought).id }
        schema '$ref' => '#/components/schemas/random_thought'
        run_test!
      end

      response(404, 'not found') do
        include_context 'when not found'
        run_test!
      end
    end
  end
end
