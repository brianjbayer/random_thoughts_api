# frozen_string_literal: true

# This application's documentation as a read-only resource
class DocumentationController < ApplicationController
  def show
    swagger_file = JSON.pretty_generate(YAML.load_file(File.open('swagger/v1/swagger.yaml')))
    render status: :ok, json: swagger_file
  end
end
