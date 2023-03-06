# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController do
  controller do
    def index
      raise StandardError, 'ruh roh'
    end
  end

  context 'when StandardError Exception' do
    before do
      get :index
    end

    it 'returns 500' do
      expect(response).to have_http_status(:internal_server_error)
    end

    it 'returns JSON' do
      expect(response.content_type).to eql('application/json; charset=utf-8')
    end

    it 'returns error JSON with 500, "internal_server_error", and supplied message' do
      expect(json_body).to be_error_json(500, 'internal_server_error', 'ruh roh')
    end
  end
end
