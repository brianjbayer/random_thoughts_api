class AddIndexToRandomThoughts < ActiveRecord::Migration[7.0]
  def change
    add_index :random_thoughts, :created_at
  end
end
