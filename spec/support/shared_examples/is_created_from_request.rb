# frozen_string_literal: true

RSpec.shared_examples 'is created from request' do |class_under_test|
  it "creates a new #{class_under_test.name}", :skip_before do
    expect do
      request
    end.to change(class_under_test, :count).by(1)
  end
end
