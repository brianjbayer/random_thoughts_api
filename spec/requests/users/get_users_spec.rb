# frozen_string_literal: true

require 'rails_helper'

require_relative '../../support/helpers/jwt_helper'
require_relative '../../support/helpers/pagination_helper'
require_relative '../../support/shared_examples/jwt_authorization'
require_relative '../../support/shared_contexts/pagination/when_at_least_three_pages'
require_relative '../../support/shared_examples/pagination/empty_paginated_page'
require_relative '../../support/shared_examples/pagination/first_paginated_page'
require_relative '../../support/shared_examples/pagination/last_paginated_page'
require_relative '../../support/shared_examples/pagination/middle_paginated_page'
require_relative '../../support/shared_examples/pagination/pagination_meta_data'

RSpec.describe 'get /users/' do
  include JwtHelper
  include PaginationHelper

  let(:valid_auth_jwt) { valid_jwt(user) }

  describe 'authorization' do
    let(:user) { create(:user) }
    let(:request_without_jwt) { get users_path, params: {} }
    let(:request_with_jwt) { get_users(jwt) }

    it_behaves_like 'jwt_authorization'
  end

  # NOTE: Since this endpoint requires authorization, there
  #       is always at least the one authorized user
  describe 'any page' do
    let(:page) { rand(1..pages) }
    # Guarantee that the requesting user is always in page
    let(:user) { User.page(page).first }

    include_context 'when at least three pages', User, :user

    before do
      get_users(valid_auth_jwt, page:)
    end

    describe 'returned "data" body' do
      it 'contains correct user information display for page' do
        all_returned = data_body
        User.page(page).each do |page_user|
          returned = all_returned.shift
          expect_correct_same_or_different_user_json(returned, page_user, user)
        end
      end
    end

    it_behaves_like 'pagination_meta_data'
  end

  describe 'first page' do
    subject(:first_page_request) { get_users(valid_auth_jwt, page: first_page) }

    let(:first_page) { 1 }
    let(:user) { User.page(first_page).first }

    include_context 'when at least three pages', User, :user

    it_behaves_like 'first paginated page'
  end

  describe 'last page' do
    subject(:last_page_request) { get_users(valid_auth_jwt, page: pages) }

    let(:user) { User.page(pages).first }

    include_context 'when at least three pages', User, :user

    it_behaves_like 'last paginated page'
  end

  describe 'middle page' do
    subject(:middle_page_request) { get_users(valid_auth_jwt, page: middle_page) }

    let(:middle_page) { 2 }
    let(:user) { User.page(middle_page).first }

    include_context 'when at least three pages', User, :user

    it_behaves_like 'middle paginated page'
  end

  private

  def get_users(jwt, page: false)
    if page
      get users_path({ page: }), headers: authorization_header(jwt)
    else
      get users_path, headers: authorization_header(jwt)
    end
  end

  def expect_correct_same_or_different_user_json(returned, page_user, user)
    if page_user == user
      expect(returned).to be_same_user_json(user)
    else
      expect(returned).to be_different_user_json(page_user)
    end
  end
end
