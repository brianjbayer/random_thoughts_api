class ChangeRandomThoughtsNotNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null(:random_thoughts, :thought, false)
    change_column_null(:random_thoughts, :name, false)
  end
end
