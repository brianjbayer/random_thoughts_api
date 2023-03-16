class AddMoodToRandomThoughts < ActiveRecord::Migration[7.0]
  def change
    add_column :random_thoughts, :mood, :string, null: false
  end
end
