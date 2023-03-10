class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension(:citext)
    create_table :users do |t|
      t.citext :email, null: false, index: { unique: true }
      t.check_constraint '(length(email) < 255)', name: 'email_length_check'

      t.string :display_name, null: false

      t.timestamps
    end
  end
end
