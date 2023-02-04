# frozen_string_literal: true

RSpec.shared_examples 'random thought response' do
  it 'returns random_thought JSON with correct values' do
    expect(json_body).to be_random_thought_json(random_thought)
  end
end
