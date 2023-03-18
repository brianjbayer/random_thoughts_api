# frozen_string_literal: true

# Database Migration to add an index to the created_at timestamp
# of the Random Thoughts (must be separate migration after the
# timestamp fields are created by the Create migration)
class AddCreatedAtIndexToRandomThoughts < ActiveRecord::Migration[7.0]
  def change
    add_index :random_thoughts, :created_at
  end
end
