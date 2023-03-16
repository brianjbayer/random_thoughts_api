# frozen_string_literal: true

RSpec.shared_examples 'bad request schema' do
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
