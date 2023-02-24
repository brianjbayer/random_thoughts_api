# frozen_string_literal: true

require 'rails_helper'

require_relative '../support/helpers/login_helper'
require_relative '../support/shared_examples/unauthorized_response'

RSpec.describe 'post /login' do
  include LoginHelper

  let(:valid_user) { create(:user) }

  context 'when valid login credentials' do
    it 'logs that the user has been authenticated' do
      allow(Rails.logger).to receive(:info)
      post_login(valid_user)
      expect(Rails.logger).to have_received(:info).with("Login: Authenticated user [#{valid_user.email}]")
    end
  end

  context 'when incorrect password' do
    before do |_example|
      valid_user.password = 'invalid'
      post_login(valid_user)
    end

    it_behaves_like 'unauthorized response'
  end

  context 'when incorrect email' do
    before do
      valid_user.email = 'invalid@wrong.com'
      post_login(valid_user)
    end

    it_behaves_like 'unauthorized response'
  end

  private

  def post_login(user)
    post login_path, params: build_login_body(user)
  end
end
