# frozen_string_literal: true

RSpec.shared_examples 'empty_paginated page' do
  before do
    any_page_request
  end

  describe 'returned "data" body' do
    it 'contains [] (empty array)' do
      expect(data_body).to eql([])
    end
  end

  describe 'returned "meta" body' do
    it 'contains requested page in "current_page"' do
      expect(metadata_body['current_page']).to eql(any_page)
    end

    it 'contains "next_page": nil' do
      expect(metadata_body['next_page']).to be_nil
    end

    it 'contains "prev_page": nil' do
      expect(metadata_body['prev_page']).to be_nil
    end

    it 'contains "total_pages": 0' do
      expect(metadata_body['total_pages']).to be(0)
    end

    it 'contains "total_count": 0' do
      expect(metadata_body['total_count']).to be(0)
    end
  end
end
