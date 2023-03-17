# frozen_string_literal: true

RSpec.shared_examples 'unauthorized schema' do |message|
  schema '$ref' => '#/components/schemas/error'
  example 'application/json', :unauthorized, {
    status: 401,
    error: 'unauthorized',
    message:
  }
end
