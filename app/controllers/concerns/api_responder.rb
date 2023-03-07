# frozen_string_literal: true

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
      render_error_status_and_json(:unprocessable_entity, error_message)
    end
  end
end
