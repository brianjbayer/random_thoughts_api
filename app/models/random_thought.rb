# frozen_string_literal: true

# Represents someone's random thought
class RandomThought < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc) }

  validates :thought, presence: true
  validates :mood, presence: true

end
