# frozen_string_literal: true

# Database Migration to create the users table (PostgreSQL)
# which persists the users of the application
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension(:citext)

    create_table :users do |t|
      t.citext :email, null: false, index: { unique: true }
      t.check_constraint '(length(email) < 255)', name: 'email_length_check'

      t.string :display_name, null: false, index: true

      t.string :password_digest

      t.bigint :authorization_min, default: -9_223_372_036_854_775_808

      t.timestamps
    end
  end
end
