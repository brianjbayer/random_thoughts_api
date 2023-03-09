# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/jwt_helper'
require_relative '../support/shared_examples/jwt_authorization'

require_relative '../support/helpers/pagination_helper'
require_relative '../support/shared_contexts/when_at_least_three_pages'
require_relative '../support/shared_contexts/when_first_paginated_page'
require_relative '../support/shared_contexts/when_last_paginated_page'
require_relative '../support/shared_contexts/when_middle_paginated_page'
require_relative '../support/shared_examples/empty_paginated_page'
require_relative '../support/shared_examples/pagination_meta_data'

RSpec.describe 'get /users/' do
  include JwtHelper
  include PaginationHelper

  let!(:user) { create(:user) }

  describe 'authorization' do
    let(:request_without_jwt) { get users_path, params: {} }
    let(:request_with_jwt) { get_users(jwt) }

    it_behaves_like 'jwt_authorization'
  end

  # TODO: Probs make this deterministic so user is on page
  context 'when there are users' do
    let(:page) { rand(1..pages) }

    include_context 'when at least three pages', User, :user

    before do
      # get random_thoughts_path({ page: })
      get_users(jwt, page)
    end

    # TODO: Not sure about this yet
    describe 'returned "data" body' do
      it 'contains correct user information display for page' do
        all_returned = data_body
        User.page(page).each do |user_on_page|
          returned = all_returned.shift
          if user_on_page == user
            expect(returned).to be_same_user_json(user)
          else
            expect(returned).to be_different_user_json(user_on_page)
          end
        end
      end

      # TODO: Implement different user display except for user

      # it 'contains all correct random thoughts for page' do
      #   all_returned = data_body
      #   RandomThought.page(page).each do |random_thought|
      #     returned = all_returned.shift
      #     expect(returned).to be_random_thought_json(random_thought)
      #   end
      # end
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

  private

  def get_users(jwt, page: false)
    # TODO: Refactor this and do the same in get_random_thoughts
    if page
     get users_path({ page: }), headers: authorization_header(jwt)
    else
      get users_path, headers: authorization_header(jwt)
    end
  end
end
