# frozen_string_literal: true

RSpec.shared_examples 'same user response' do
  it 'returns "email": email' do
    expect(json_body['email']).to eql(user.email)
  end

  it 'returns "display_name": display_name' do
    expect(json_body['display_name']).to eql(user.display_name)
  end
end
