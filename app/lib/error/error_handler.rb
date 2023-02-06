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
          render_response(500, :internal_server_error, e.to_s)
        end

        # Expected exceptions
        rescue_from ActiveRecord::RecordNotFound do |e|
          render_response(404, :not_found, e.to_s)
        end

        rescue_from ActiveRecord::RecordInvalid do |e|
          render_response(422, :unprocessable_entity, e.to_s)
        end

        rescue_from ActionController::ParameterMissing,
                    ActionDispatch::Http::Parameters::ParseError do |e|
          render_response(400, :bad_request, e.to_s)
        end
      end
    end

    private

    def render_response(status, error, message)
      json = { status:, error:, message: }.to_json
      render json:, status:
    end
  end
end
