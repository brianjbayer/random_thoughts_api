# frozen_string_literal: true

RSpec.shared_examples 'first paginated page' do
  before do
    first_page_request
  end

  it 'returned "meta" body contains "prev_page": nil' do
    expect(metadata_body['prev_page']).to be_nil
  end
end
