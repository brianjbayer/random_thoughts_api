# frozen_string_literal: true

RSpec.shared_examples 'unprocessable_entity response' do
  it 'returns error JSON with 422, "unprocessable_entity", and indicates validation failed' do
    expect(json_body).to be_error_json(422, 'unprocessable_entity', 'Validation failed: ')
  end
end
