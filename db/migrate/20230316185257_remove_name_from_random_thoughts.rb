class RemoveNameFromRandomThoughts < ActiveRecord::Migration[7.0]
  def change
    remove_column :random_thoughts, :name, :string
  end
end
