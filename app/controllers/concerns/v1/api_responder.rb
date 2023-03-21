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
        status = Rack::Utils.status_code(error)
        json = { status:, error:, message: }.to_json
        render json:, status:
      end
    end
  end
end
