# frozen_string_literal: true

# Represents someone's random thought
class RandomThought < ApplicationRecord
  default_scope -> { order(created_at: :desc) }

  validates :thought, presence: true
  validates :name, presence: true
end
