# frozen_string_literal: true

RSpec.shared_examples 'is not updated from request' do |class_under_test|
  it "does not update #{class_under_test.name}" do
    last_update = class_under_test.find(requesting.id).updated_at
    expect(last_update).to eql(requesting.created_at)
  end
end
