# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'root' do
  describe 'get /' do
    before do
      get root_path
    end

    it 'returns 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns Swagger File in Pretty JSON' do
      swagger_file_json = JSON.pretty_generate(YAML.load_file(File.open('swagger/v1/swagger.yaml')))
      expect(response.body).to eq(swagger_file_json)
    end
  end
end
