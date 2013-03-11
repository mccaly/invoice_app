class AddRememberTokenToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :remember_token, :string
  	add_index :isers, :remember_token
  end
end
