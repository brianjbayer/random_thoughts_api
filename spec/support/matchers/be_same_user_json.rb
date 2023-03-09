# frozen_string_literal: true

# Custom RSpec Matcher to match critical
# attribute values to be a user
# JSON response when the current user
# is the requested user
module BeSameUserJson
  class BeSameUserJson
    def initialize(expected_user)
      @expected_user = expected_user
    end

    def matches?(actual)
      @actual = actual

      @actual['email'] == @expected_user.email &&
        @actual['display_name'] == @expected_user.display_name
    end

    def failure_message
      "expected that actual: #{pretty(@actual)} would match " \
        "expected: #{pretty(matched_expected)}"
    end

    def failure_message_when_negated
      "expected that actual: #{pretty(@actual)} would not match " \
        "expected: #{pretty(matched_expected)}"
    end

    private

    def pretty(json)
      JSON.pretty_generate(json)
    end

    def matched_expected
      @expected_user.attributes.slice('id', 'email', 'display_name')
    end
  end

  def be_same_user_json(expected_user)
    BeSameUserJson.new(expected_user)
  end
end

# Include the custom matcher in RSpec
RSpec.configure do |config|
  config.include BeSameUserJson
end
