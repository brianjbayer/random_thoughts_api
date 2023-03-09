# frozen_string_literal: true

require_relative './when_at_least_three_pages'

RSpec.shared_context 'when last paginated page' do |class_under_test, factory_name|
  include_context 'when at least three pages', class_under_test, factory_name

  before do
    last_page_request
  end

  it 'returned "meta" body contains "next_page": nil' do
    expect(metadata_body['next_page']).to be_nil
  end
end
