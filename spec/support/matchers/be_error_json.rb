# frozen_string_literal: true

# Custom RSpec Matcher to match critical
# attribute values to be an error
# JSON response
module BeErrorJson
  class BeErrorJson
    def initialize(status, error, message)
      @status = status
      @error = error
      @message = message
      @expected_json = to_error_json(status, error, message)
    end

    def matches?(actual)
      @actual = actual

      @actual['status'] == @status &&
        @actual['error'] == @error &&
        @actual['message'].include?(@message)
    end

    def failure_message
      "expected that actual: #{pretty(@actual)} would match " \
        "expected: #{pretty(@expected_json)}"
    end

    def failure_message_when_negated
      "expected that actual: #{pretty(@actual)} would not match " \
        "expected: #{pretty(@expected_json)}"
    end

    private

    def pretty(json)
      JSON.pretty_generate(json)
    end

    def to_error_json(status, error, message)
      {
        status:,
        error:,
        message:
      }
    end
  end

  def be_error_json(status, error, message)
    BeErrorJson.new(status, error, message)
  end
end

# Include the custom matcher in RSpec
RSpec.configure do |config|
  config.include BeErrorJson
end
