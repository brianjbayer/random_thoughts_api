# frozen_string_literal: true

require 'rails_helper'

require_relative '../../support/helpers/pagination_helper'
require_relative '../../support/shared_contexts/pagination/when_at_least_three_pages'
require_relative '../../support/shared_contexts/pagination/when_first_paginated_page'
require_relative '../../support/shared_contexts/pagination/when_last_paginated_page'
require_relative '../../support/shared_contexts/pagination/when_middle_paginated_page'
require_relative '../../support/shared_examples/pagination/empty_paginated_page'
require_relative '../../support/shared_examples/pagination/pagination_meta_data'

RSpec.describe 'get /random_thoughts/' do
  include PaginationHelper

  context 'when there are random_thoughts' do
    let(:page) { rand(1..pages) }

    include_context 'when at least three pages', RandomThought, :random_thought

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
          expect(returned).to be_random_thought_json(random_thought, random_thought.user)
        end
      end
    end

    it_behaves_like 'pagination_meta_data'
  end

  describe 'first page' do
    subject(:first_page_request) { get random_thoughts_path({ page: 1 }) }

    include_context 'when first paginated page', RandomThought, :random_thought
  end

  describe 'last page' do
    subject(:last_page_request) { get random_thoughts_path({ page: pages }) }

    include_context 'when last paginated page', RandomThought, :random_thought
  end

  describe 'middle page' do
    subject(:middle_page_request) { get random_thoughts_path({ page: middle_page }) }

    let(:middle_page) { 2 }

    include_context 'when middle paginated page', RandomThought, :random_thought
  end

  context 'when there are no random thoughts' do
    subject(:any_page_request) { get random_thoughts_path({ page: any_page }) }

    let(:any_page) { 1 }

    it_behaves_like 'empty_paginated page'
  end
end
