class AddDisplayNameIndexToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :display_name
  end
end
