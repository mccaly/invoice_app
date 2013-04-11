class AddAccountAndUserIdToUnit < ActiveRecord::Migration
  def change
  	add_column :units, :account_id, :integer
  	add_column :units, :user_id, :integer
  end
end
