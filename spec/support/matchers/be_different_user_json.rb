# frozen_string_literal: true

# Custom RSpec Matcher to ensure
# only expected attributes
# and their correct values
# for a user JSON response
# when the current user
# is not the requested user
module BeDifferentUserJson
  class BeDifferentUserJson
    def initialize(expected_user)
      @expected_user = expected_user
    end

    def matches?(actual)
      @actual = actual

      # Ensure only expected attributes are present and match values
      @actual.keys == only_allowed_attributes &&
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

    def only_allowed_attributes
      ['display_name']
    end

    def pretty(json)
      JSON.pretty_generate(json)
    end

    def matched_expected
      @expected_user.attributes.slice(*only_allowed_attributes)
    end
  end

  def be_different_user_json(expected_user)
    BeDifferentUserJson.new(expected_user)
  end
end

# Include the custom matcher in RSpec
RSpec.configure do |config|
  config.include BeDifferentUserJson
end
