# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'get /random_thoughts/' do
  shared_context 'when there are at least three pages' do
    let(:pages) { 3 }
    let(:per_page) { RandomThought.page.limit_value }
    let(:num_random_thoughts) { (per_page * (pages - 1)) + 1 }

    before do
      create_list(:random_thought, num_random_thoughts)
    end
  end
  context 'when there are random_thoughts' do
    let(:page) { rand(1..pages) }

    include_context 'when there are at least three pages'

    before do
      get random_thoughts_path({ page: })
    end

    describe 'returned "data" body' do
      it 'contains all correct random thought "id"s for page' do
        all_returned = data_body
        RandomThought.page(page).each do |random_thought|
          returned = all_returned.shift
          expect(returned['id']).to be(random_thought.id)
        end
      end

      it 'contains all correct random thoughts for page' do
        all_returned = data_body
        RandomThought.page(page).each do |random_thought|
          returned = all_returned.shift
          expect(returned).to be_random_thought_json(random_thought)
        end
      end
    end

    describe 'returned "meta" body' do
      it 'contains requested page in "current_page"' do
        expect(metadata_body['current_page']).to eql(page)
      end

      it 'contains correct number in "total_pages"' do
        expect(metadata_body['total_pages']).to be(pages)
      end

      it 'contains correct total in "total_count"' do
        expect(metadata_body['total_count']).to be(num_random_thoughts)
      end
    end
  end

  context 'when first page requested' do
    include_context 'when there are at least three pages'

    before do
      get random_thoughts_path({ page: 1 })
    end

    describe 'returned "meta" body' do
      it 'contains "prev_page": nil' do
        expect(metadata_body['prev_page']).to be_nil
      end
    end
  end

  context 'when last page requested' do
    include_context 'when there are at least three pages'

    before do
      get random_thoughts_path({ page: pages })
    end

    describe 'returned "meta" body' do
      it 'contains "next_page": nil' do
        expect(metadata_body['next_page']).to be_nil
      end
    end
  end

  context 'when page in middle requested' do
    let(:middle_page) { 2 }

    include_context 'when there are at least three pages'

    before do
      get random_thoughts_path({ page: middle_page })
    end

    describe 'returned "meta" body' do
      it 'contains correct "next_page"' do
        expect(metadata_body['next_page']).to be(middle_page + 1)
      end

      it 'contains correct "prev_page"' do
        expect(metadata_body['prev_page']).to be(middle_page - 1)
      end
    end
  end

  context 'when there are no random thoughts' do
    let(:page) { 1 }

    before do
      get random_thoughts_path({ page: })
    end

    describe 'returned "data" body' do
      it 'contains [] (empty array)' do
        expect(data_body).to eql([])
      end
    end

    describe 'returned "meta" body' do
      it 'contains requested page in "current_page"' do
        expect(metadata_body['current_page']).to eql(page)
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

  private

  def data_body
    json_body['data']
  end

  def metadata_body
    json_body['meta']
  end
end
