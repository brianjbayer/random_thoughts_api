# frozen_string_literal: true

RSpec.shared_examples 'random thought response' do
  it 'returns integer "id":' do
    expect(json_body['id']).to be_a(Integer)
  end

  it 'returns "thought": thought' do
    expect(json_body['thought']).to eql(random_thought.thought)
  end

  it 'returns "name": name' do
    expect(json_body['name']).to eql(random_thought.name)
  end
end
