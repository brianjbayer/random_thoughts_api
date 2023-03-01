# frozen_string_literal: true

module Error
  # Handles expected and unexpected errors in a controlled manner
  # and message
  module ErrorHandler
    def self.included(including_class)
      # Handlers must be ordered in lowest to highest priority
      # (i.e. default must be first)
      including_class.class_eval do
        # Default catch-all exception
        rescue_from StandardError do |e|
          render_error_response(:internal_server_error, e.to_s)
        end

        # Expected exceptions
        rescue_from ActiveRecord::RecordNotFound do |e|
          render_error_response(:not_found, e.to_s)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          render_error_response(:unprocessable_entity, e.to_s)
        end

        rescue_from ActionController::ParameterMissing,
                    ActionDispatch::Http::Parameters::ParseError do |e|
          render_error_response(:bad_request, e.to_s)
        end

        #--- JWT Errors ---
        # JWT::DecodeError is the base decoding error
        rescue_from JWT::DecodeError do |e|
          render_error_response(:unauthorized, e.to_s)
        end

        rescue_from JWT::InvalidAudError, JWT::InvalidIssuerError do |e|
          # Don't leak the expected value which comes after '.'
          render_error_response(:unauthorized, e.to_s.split('.')[0])
        end
      end
    end

    def render_error_response(error, message)
      status = Rack::Utils.status_code(error)
      json = { status:, error:, message: }.to_json
      render json:, status:
    end
  end
end
