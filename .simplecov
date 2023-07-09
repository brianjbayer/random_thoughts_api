# frozen_string_literal: true

require 'simplecov-console'

SimpleCov.start 'rails' do
  enable_coverage :branch

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
    [
      SimpleCov::Formatter::HTMLFormatter,
      SimpleCov::Formatter::Console
    ]
  )
  # Use the more concise 'block' vs the default table output
  SimpleCov::Formatter::Console.output_style = 'block'
end
