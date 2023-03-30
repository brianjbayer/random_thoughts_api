# frozen_string_literal: true

module Rack
  # Health check to ensure the database is ready for traffic
  class ReadyCheck
    def initialize
      @body_details = {}
    end

    def call(_env)
      response = ready? ? ready_response : error_response
      response.finish
    end

    def ready?
      database_connected?
      database_migrations?
    end

    def database_connected?
      ActiveRecord::Base.connection.execute('SELECT 1')
      @body_details[:database_connection] = 'ok'
    rescue StandardError
      @body_details[:database_connection] = 'error'
      false
    end

    def database_migrations?
      ActiveRecord::Migration.check_pending!
      @body_details[:database_migrations] = 'ok'
    rescue StandardError
      @body_details[:database_migrations] = 'pending'
      false
    end

    def ready_response
      status = 200
      response_body = { status:, message: 'ready' }.merge(@body_details)
      rack_response(response_body, status)
    end

    def error_response
      status = 503
      response_body = { status:, message: 'error' }.merge(@body_details)
      rack_response(response_body, status)
    end

    def rack_response(body, status)
      Rack::Response.new(
        body.to_json,
        status,
        response_header
      )
    end

    def response_header
      { 'Content-type' => 'application/json; charset=utf-8' }
    end
  end
end
