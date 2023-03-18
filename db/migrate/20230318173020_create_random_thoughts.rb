# frozen_string_literal: true

# Database Migration to create the random_thoughts table (PostgreSQL)
# which persists the Random Thoughts of the users of the application
class CreateRandomThoughts < ActiveRecord::Migration[7.0]
  def change
    create_table :random_thoughts do |t|
      t.string :thought, null: false
      t.string :mood, null: false

      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
