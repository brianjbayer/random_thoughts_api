# frozen_string_literal: true

require_relative './when_at_least_three_pages'

RSpec.shared_context 'when middle paginated page' do |class_under_test, factory_name|
  include_context 'when at least three pages', class_under_test, factory_name

  before do
    middle_page_request
  end

  it 'contains correct "next_page"' do
    expect(metadata_body['next_page']).to be(middle_page + 1)
  end

  it 'contains correct "prev_page"' do
    expect(metadata_body['prev_page']).to be(middle_page - 1)
  end
end
