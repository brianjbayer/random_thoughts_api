   # frozen_string_literal: true

   # Add Factory Bot Methods to spec DSL

   RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
  end
