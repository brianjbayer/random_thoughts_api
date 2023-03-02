class AddAuthorizationMinToUsers < ActiveRecord::Migration[7.0]
  def change
    # This assume PostgreSQL where -9223372036854775808 is lowesrt bigint value
    add_column :users, :authorization_min, :bigint, default: -9223372036854775808
  end
end
