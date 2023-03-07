# frozen_string_literal: true

RSpec.shared_examples 'is deleted from request' do |class_under_test|
  it "deletes a #{class_under_test.name}", :skip_before do
    expect do
      delete_request
    end.to change(class_under_test, :count).by(-1)
  end

  it "deletes the #{class_under_test.name.downcase}" do
    expect(class_under_test.find_by(id: object_to_delete.id)).to be_nil
  end
end
