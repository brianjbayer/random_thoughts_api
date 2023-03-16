# frozen_string_literal: true

# Custom RSpec Matcher to match critical
# attribute values to be a random_thought
# JSON response
module BeRandomThoughtJson
  class BeRandomThoughtJson
    def initialize(expected_thought, user)
      @expected_thought = expected_thought
      @user = user
    end

    def matches?(actual)
      @actual = actual

      @actual['thought'] == @expected_thought.thought &&
        @actual['name'] == @user.display_name &&
        @actual['mood'] == @expected_thought.mood
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
      expected = @expected_thought.attributes.slice('id', 'thought', 'mood')
      expected['name'] = @user.display_name
      expected
    end
  end

  def be_random_thought_json(expected_thought, user)
    BeRandomThoughtJson.new(expected_thought, user)
  end
end

# Include the custom matcher in RSpec
RSpec.configure do |config|
  config.include BeRandomThoughtJson
end
