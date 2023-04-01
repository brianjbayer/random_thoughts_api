# frozen_string_literal: true

# This is default configuration intended to be common across
# all environments.  Any environment-specific overides to
# these defaults should be done in that specific environment's
# configuration file.
# NOTE: Settings specified here will take precedence over those
# in config/application.rb.

# TODO: This is currently a Work In Progress and will fully
# addressed during productionization

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  #--- SSL/HTTPS ---
  # Note this is modified from config/environments/production.rb
  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = ENV.include?('RAILS_FORCE_SSL')

  #--- LOGGING ---
  # Note this is modified from config/environments/production.rb
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id]

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = Logger::Formatter.new

  if ENV.include?('RAILS_LOG_TO_STDOUT')
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # --- SECRET KEY BASE ---
  # NOTE: This application does not use the secret key base
  #       But rails needs it
  config.secret_key_base = ENV.fetch('SECRET_KEY_BASE')

  #--- APPLICATION-SPECIFIC CONFIGURATION ---
  config.jwt_secret = ENV.fetch('APP_JWT_SECRET')

  # Make all (i.e. development) environments the same
  # which is allow all hosts
  config.hosts.clear
end
