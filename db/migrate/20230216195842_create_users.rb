class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension(:citext)
    create_table :users do |t|
      t.citext :email, null: false, index: { unique: true }
      t.string :display_name, null: false

      t.timestamps
    end
  end
end
