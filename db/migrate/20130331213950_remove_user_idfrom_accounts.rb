class RemoveUserIdfromAccounts < ActiveRecord::Migration
  def up
  	remove_column :accounts, :user_id
  	change_table :accounts do |t|
  		t.references :user
  	end
  end

  def down
  	remove_column :accounts, :user
  	add_column :accounts, :user_id, :integer
  end
end
