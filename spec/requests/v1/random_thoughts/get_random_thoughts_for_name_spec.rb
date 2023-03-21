# frozen_string_literal: true

require 'rails_helper'

require_relative '../../../support/helpers/pagination_helper'
require_relative '../../../support/shared_examples/pagination/empty_paginated_page'
require_relative '../../../support/shared_examples/pagination/first_paginated_page'
require_relative '../../../support/shared_examples/pagination/last_paginated_page'
require_relative '../../../support/shared_examples/pagination/middle_paginated_page'
require_relative '../../../support/shared_examples/pagination/pagination_meta_data'

RSpec.describe 'get /v1/random_thoughts/?name={display_name}' do
  include PaginationHelper

  shared_context 'when at least three pages for name' do
    let(:pages) { 3 }
    let(:per_page) { RandomThought.page.limit_value }
    let(:num_items) { (per_page * (pages - 1)) + 1 }
    let(:user) { create(:user) }

    before do
      create_list(:random_thought, num_items, user:)
      # Create at least one random thought by another user
      create(:random_thought)
    end
  end

  context 'when there are random_thoughts for name' do
    let(:page) { rand(1..pages) }

    include_context 'when at least three pages for name'

    before do
      get_random_thoughts_for_name(page, user.display_name)
    end

    describe 'returned "data" body' do
      it 'contains all of name\'s correct random thought "id"s for page' do
        all_returned = data_body
        paginated_random_thoughts_for_name(user).each do |random_thought|
          returned = all_returned.shift
          expect(returned['id']).to be(random_thought.id)
        end
      end

      it 'contains all of name\'s correct random thoughts for page' do
        all_returned = data_body
        paginated_random_thoughts_for_name(user).each do |random_thought|
          returned = all_returned.shift
          expect(returned).to be_random_thought_json(random_thought, user)
        end
      end
    end

    it_behaves_like 'pagination_meta_data'
  end

  describe 'first page for name' do
    subject(:first_page_request) { get_random_thoughts_for_name(1, user.display_name) }

    include_context 'when at least three pages for name'

    it_behaves_like 'first paginated page'
  end

  describe 'last page' do
    subject(:last_page_request) { get_random_thoughts_for_name(pages, user.display_name) }

    include_context 'when at least three pages for name'

    it_behaves_like 'last paginated page'
  end

  describe 'middle page' do
    subject(:middle_page_request) { get_random_thoughts_for_name(middle_page, user.display_name) }

    let(:middle_page) { 2 }

    include_context 'when at least three pages for name'

    it_behaves_like 'middle paginated page'
  end

  context 'when there are no random thoughts for name' do
    subject(:any_page_request) { get_random_thoughts_for_name(any_page, user.display_name) }

    let(:any_page) { 1 }
    let(:user) { create(:user) }

    it_behaves_like 'empty_paginated page'
  end

  private

  def get_random_thoughts_for_name(page, name)
    get v1_random_thoughts_path({ page:, name: })
  end

  def paginated_random_thoughts_for_name(user)
    RandomThought.joins(:user).where(user: { display_name: user.display_name }).page(page)
  end
end
