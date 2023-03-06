# frozen_string_literal: true

RSpec.shared_examples 'is not deleted from request' do |class_under_test|
  it "does not delete a #{class_under_test.name}", :skip_before do
    expect do
      delete_request
    end.not_to change(class_under_test, :count)
  end
end
