source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.4.2"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8"

# Pin concurrent-ruby to 1.3.4 until upgrade to Rails 7.1
# https://stackoverflow.com/questions/79360526/uninitialized-constant-activesupportloggerthreadsafelevellogger-nameerror
gem 'concurrent-ruby', '1.3.4'

# Gems no longer loaded from standard library
gem "benchmark"
gem "bigdecimal"
gem "drb"
gem "logger"
gem "mutex_m"
gem "ostruct"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.6"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# TODO: Pin to version 2.0.0 until CVE-2024-27456 in 2.0.1 is addressed
gem "rack-cors", "2.0.0"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]

  # - CUSTOM -
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  # Swagger specs
  gem 'rswag-specs'
  gem 'rubocop', require: false
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'simplecov-console', require: false
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

# --- CUSTOM GEMS ---
# JSON Web Token for Authentication
gem 'jwt'

# Pagination
gem 'kaminari'

# Add Swagger/OpenAPI endpoints to all environments
gem 'rswag-api'
gem 'rswag-ui'

group :test do
  gem 'shoulda-matchers'
end
