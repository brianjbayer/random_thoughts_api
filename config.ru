# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

run Rails.application
Rails.application.load_server

# --- CUSTOM ---
# Add health checks
require_relative 'lib/rack/live_check'
require_relative 'lib/rack/ready_check'

map '/livez' do
  run Rack::LiveCheck.new
end

map '/readyz' do
  run Rack::ReadyCheck.new
end
