# frozen_string_literal: true

# Module for rendering Common Response in Controllers
module RenderResponseConcern
  extend ActiveSupport::Concern
  included do
    def render_show_response(status)
      # FYI: render 'show' renders views/<view-name>/show.json.jbuilder
      render 'show', status:
    end
  end
end
