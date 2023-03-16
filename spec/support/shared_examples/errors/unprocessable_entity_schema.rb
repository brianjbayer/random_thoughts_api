# frozen_string_literal: true

RSpec.shared_examples 'unprocessable entity schema' do |message|
  schema '$ref' => '#/components/schemas/error'
  example 'application/json', :unprocessable_entity, {
    status: 422,
    error: 'unprocessable_entity',
    message:
  }
end
