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
  #--- LOGGING ---
  # Note this is modified from config/environments/production.rb
  if ENV.include?('RAILS_LOG_TO_STDOUT')
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  #--- APPLICATION-SPECIFIC CONFIGURATION ---
  config.jwt_secret = ENV.fetch('APP_JWT_SECRET')
end
