# frozen_string_literal: true

module Rack
  # Most basic health check that simply indicates that the application is up
  # but not necessarily ready for traffic
  class LiveCheck
    def call(_env)
      # Must be alive to reach this
      [
        200,
        { 'Content-type' => 'application/json; charset=utf-8' },
        ['{ "status": 200, "message": "alive" }']
      ]
    end
  end
end
