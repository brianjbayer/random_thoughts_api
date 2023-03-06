# frozen_string_literal: true

RSpec.shared_examples 'not_found response' do
  it 'returns error JSON with 404, "not_found", and indicates could not find' do
    expect(json_body).to be_error_json(404, 'not_found', "Couldn't find ")
  end
end
