# frozen_string_literal: true

module ApiHelper
  def json_body
    JSON.parse(response.body)
  end

  def empty_json_body
    {}
  end

  def json_body_just_keys(top_key, update, *)
    update_just_key = {}
    update_just_key[top_key] = update[top_key].slice(*)
    update_just_key
  end
end

RSpec.configure do |config|
  config.include ApiHelper, type: :controller
  config.include ApiHelper, type: :request
end
