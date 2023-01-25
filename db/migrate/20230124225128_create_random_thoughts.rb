class CreateRandomThoughts < ActiveRecord::Migration[7.0]
  def change
    create_table :random_thoughts do |t|
      t.string :thought
      t.string :name

      t.timestamps
    end
  end
end
