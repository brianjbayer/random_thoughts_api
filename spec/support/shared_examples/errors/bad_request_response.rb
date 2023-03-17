# frozen_string_literal: true

RSpec.shared_examples 'bad_request response' do
  it 'returns error JSON with 400, "bad_request", and indicates parameter/value is missing' do
    expect(json_body).to be_error_json(400,
                                       'bad_request',
                                       'param is missing or the value is empty')
  end
end
