#!/usr/bin/env ruby
# ----------------------------------------------------------------------
# Simple script to query locally running Ruby application to determine
# if it is up and ready.  Generally intended as a healthcheck for
# container orchestration where curl/wget is not available
# ASSUMPTIONS:
#   1. readiness endpoint is /readyz
#   2. readiness endpoint returns 200 if ready
# ----------------------------------------------------------------------
require 'net/http'
require 'uri'

def ready_endpoint
  port = ENV.fetch('PORT', 3000)
  "http://localhost:#{port}/readyz"
end

begin
  uri = URI.parse(ready_endpoint)
  response = Net::HTTP.get_response(uri)
rescue StandardError
  exit(1)
end

# rubocop:disable Style/TernaryParentheses
puts "Received response code [#{response.code}]"
exit_code = (response.code == '200') ? 0 : 1
# rubocop:enable Style/TernaryParentheses
exit(exit_code)
