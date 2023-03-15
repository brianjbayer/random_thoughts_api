class AddUserToRandomThought < ActiveRecord::Migration[7.0]
  def change
    add_reference :random_thoughts, :user, null: false, foreign_key: true, index: true
  end
end
