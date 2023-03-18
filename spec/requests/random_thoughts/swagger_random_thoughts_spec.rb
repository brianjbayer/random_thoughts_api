# frozen_string_literal: true

require 'swagger_helper'

require_relative '../../support/helpers/jwt_helper'
require_relative '../../support/helpers/random_thought_helper'
require_relative '../../support/shared_examples/errors/bad_request_schema'
require_relative '../../support/shared_examples/errors/not_found_schema'
require_relative '../../support/shared_examples/errors/unauthorized_schema'
require_relative '../../support/shared_examples/errors/unprocessable_entity_schema'

class RandomThoughtMessage
  def self.not_found
    "Couldn't find RandomThought with 'id'=??"
  end
end

RSpec.describe 'random_thoughts' do
  include JwtHelper
  include RandomThoughtHelper

  # rubocop:disable RSpec/VariableName
  let(:Authorization) { "Bearer #{jwt}" }
  # rubocop:enable RSpec/VariableName
  let(:user) { create(:user) }
  let(:jwt) { valid_jwt(user) }

  path '/random_thoughts' do
    get('list random_thoughts') do
      consumes 'application/json'
      produces 'application/json'
      parameter name: 'page',
                in: :query,
                type: :integer,
                description: 'page number',
                required: false
      parameter name: 'name',
                in: :query,
                type: :string,
                description: 'user name',
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
      security [bearer: []]
      parameter name: :random_thought,
                in: :body,
                schema: { '$ref' => '#/components/schemas/create_random_thought' }

      let(:random_thought) { build_random_thought_body(build(:random_thought)) }

      response(201, 'created') do
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(400, 'bad request') do
        let(:random_thought) { empty_json_body }
        it_behaves_like 'bad request schema'
        run_test!
      end

      response(401, 'unauthorized') do
        let(:jwt) { invalid_signature_jwt(user) }
        it_behaves_like 'unauthorized schema', 'Signature verification failed'
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:random_thought) { build_random_thought_body(build(:random_thought, :empty)) }
        msg = "Validation failed: Thought can't be blank, Mood can't be blank"
        it_behaves_like 'unprocessable entity schema', msg
        run_test!
      end
    end
  end

  path '/random_thoughts/{id}' do
    parameter name: 'id', in: :path, type: :string, description: 'id'

    # Create RandomThought associated with User
    let(:id) { create(:random_thought, user:).id }

    get('show random_thought') do
      consumes 'application/json'
      produces 'application/json'

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        it_behaves_like 'not found schema', RandomThoughtMessage.not_found
        run_test!
      end
    end

    patch('update random_thought') do
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]
      parameter name: :update,
                in: :body,
                schema: { '$ref' => '#/components/schemas/update_random_thought' }

      let(:update) { build_random_thought_body(build(:random_thought)) }

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(400, 'bad request') do
        let(:update) { empty_json_body }
        it_behaves_like 'bad request schema'
        run_test!
      end

      response(401, 'unauthorized') do
        let(:jwt) { invalid_signature_jwt(user) }
        it_behaves_like 'unauthorized schema', 'Signature verification failed'
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        it_behaves_like 'not found schema', RandomThoughtMessage.not_found
        run_test!
      end

      response(422, 'unprocessable entity') do
        msg = "Validation failed: Thought can't be blank, Mood can't be blank"
        it_behaves_like 'unprocessable entity schema', msg
        let(:empty_values) { build_random_thought_body(build(:random_thought, :empty)) }
        let(:update) { empty_values }
        run_test!
      end
    end

    delete('delete random_thought') do
      consumes 'application/json'
      produces 'application/json'
      security [bearer: []]

      response(200, 'successful') do
        schema '$ref' => '#/components/schemas/random_thought_response'
        run_test!
      end

      response(401, 'unauthorized') do
        let(:jwt) { invalid_signature_jwt(user) }
        it_behaves_like 'unauthorized schema', 'Signature verification failed'
        run_test!
      end

      response(404, 'not found') do
        let(:id) { 0 }
        it_behaves_like 'not found schema', RandomThoughtMessage.not_found
        run_test!
      end
    end
  end
end
