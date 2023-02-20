# frozen_string_literal: true

module ApiHelper
  def json_body
    JSON.parse(response.body)
  end

  def empty_json_body
    {}
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :controller
  config.include ApiHelper, type: :request
end
