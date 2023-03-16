# frozen_string_literal: true

RSpec.shared_examples 'pagination_meta_data' do
  it 'contains requested page in "current_page"' do
    expect(metadata_body['current_page']).to eql(page)
  end

  it 'contains correct number in "total_pages"' do
    expect(metadata_body['total_pages']).to be(pages)
  end

  it 'contains correct total in "total_count"' do
    expect(metadata_body['total_count']).to be(num_items)
  end
end
