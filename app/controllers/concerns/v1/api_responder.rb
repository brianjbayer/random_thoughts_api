# frozen_string_literal: true

module V1
  # Module for rendering Common Response in Controllers
  module ApiResponder
    extend ActiveSupport::Concern

    included do
      def render_show_response(status)
        # FYI: render 'show' renders views/<view-name>/show.json.jbuilder
        render 'show', status:
      end

      def render_validation_error_response(obj)
        error_message = "Validation failed: #{obj.errors.full_messages.join(', ')}"
        render_error_response(:unprocessable_entity, error_message)
      end

      def render_error_response(error, message)
        error_name = error.to_s
        rack_error = error_name == 'unprocessable_entity' ? :unprocessable_content : error
        status = Rack::Utils.status_code(rack_error)
        json = { status:, error: error_name, message: }.to_json
        render json:, status:
      end
    end
  end
end
