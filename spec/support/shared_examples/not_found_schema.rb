# frozen_string_literal: true

RSpec.shared_examples 'not found schema' do |message|
  schema '$ref' => '#/components/schemas/error'
  example 'application/json', :not_found, {
    status: 404,
    error: 'not_found',
    message:
  }
end
