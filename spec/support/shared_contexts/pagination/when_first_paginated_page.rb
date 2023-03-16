# frozen_string_literal: true

require_relative './when_at_least_three_pages'

RSpec.shared_context 'when first paginated page' do |class_under_test, factory_name|
  include_context 'when at least three pages', class_under_test, factory_name

  before do
    first_page_request
  end

  it 'returned "meta" body contains "prev_page": nil' do
    expect(metadata_body['prev_page']).to be_nil
  end
end
