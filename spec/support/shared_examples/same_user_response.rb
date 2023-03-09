# frozen_string_literal: true

RSpec.shared_examples 'same user response' do
  it 'returns same user JSON with correct values' do
    expect(json_body).to be_same_user_json(user)
  end
end
