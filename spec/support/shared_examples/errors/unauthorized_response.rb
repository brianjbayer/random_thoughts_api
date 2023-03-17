# frozen_string_literal: true

RSpec.shared_examples 'unauthorized response' do |message|
  it "returns error JSON with 401, \"unauthorized\", and indicates #{message}" do
    expect(json_body).to be_error_json(401, 'unauthorized', message)
  end
end
