# frozen_string_literal: true

RSpec.shared_examples 'last paginated page' do
  before do
    last_page_request
  end

  it 'returned "meta" body contains "next_page": nil' do
    expect(metadata_body['next_page']).to be_nil
  end
end
