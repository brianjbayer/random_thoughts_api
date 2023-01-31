# frozen_string_literal: true

# Represents someone's random thought
class RandomThought < ApplicationRecord
  default_scope -> { order(created_at: :desc) }
end
