# frozen_string_literal: true

RSpec.shared_examples 'is not created from request' do |class_under_test|
  it "does not create a new #{class_under_test.name}", :skip_before do
    expect do
      request
    end.not_to change(class_under_test, :count)
  end
end
