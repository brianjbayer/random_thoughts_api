# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../support/helpers/pagination_helper'
require_relative '../../../support/shared_contexts/pagination/when_at_least_three_pages'
require_relative '../../../support/shared_examples/pagination/empty_paginated_page'
require_relative '../../../support/shared_examples/pagination/first_paginated_page'
require_relative '../../../support/shared_examples/pagination/last_paginated_page'
require_relative '../../../support/shared_examples/pagination/middle_paginated_page'
require_relative '../../../support/shared_examples/pagination/pagination_meta_data'

RSpec.describe 'get /v1/random_thoughts/' do
  include PaginationHelper

  context 'when there are random_thoughts' do
    let(:page) { rand(1..pages) }

    include_context 'when at least three pages', RandomThought, :random_thought

    before do
      get_random_thoughts(page:)
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

  context 'when there is not an optional page query parameter' do
    subject(:first_page_request) { get_random_thoughts }

    include_context 'when at least three pages', RandomThought, :random_thought

    it_behaves_like 'first paginated page'
  end

  describe 'first page' do
    subject(:first_page_request) { get_random_thoughts(page: 1) }

    include_context 'when at least three pages', RandomThought, :random_thought

    it_behaves_like 'first paginated page'
  end

  describe 'last page' do
    subject(:last_page_request) { get_random_thoughts(page: pages) }

    include_context 'when at least three pages', RandomThought, :random_thought

    it_behaves_like 'last paginated page'
  end

  describe 'middle page' do
    subject(:middle_page_request) { get_random_thoughts(page: middle_page) }

    let(:middle_page) { 2 }

    include_context 'when at least three pages', RandomThought, :random_thought

    it_behaves_like 'middle paginated page'
  end

  context 'when there are no random thoughts' do
    subject(:any_page_request) { get_random_thoughts(page: any_page) }

    let(:any_page) { 1 }

    it_behaves_like 'empty_paginated page'
  end

  private

  def get_random_thoughts(page: false)
    get path_with_optional_page(method(:v1_random_thoughts_path), page:)
  end
end
