# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  open_public_access = '*'

  # FOR NOW allow open public access to healthchecks but these
  # should probably be restricted to localhost, same network zone.
  # and our health monitoring services
  allow do
    origins open_public_access

    resource '/livez, /readyz',
             headers: :any,
             methods: [:get]
  end

  # For the API-documenting root route, allow open public access
  allow do
    origins open_public_access

    resource '/',
             headers: :any,
             methods: [:get]
  end

  # For the API endpoints themselves (including root), allow open public access
  allow do
    origins open_public_access

    resource '/v1/*',
             headers: :any,
             methods: %i[get post patch delete]
  end
end
