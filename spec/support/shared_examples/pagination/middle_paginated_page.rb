# frozen_string_literal: true

RSpec.shared_examples 'middle paginated page' do
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
