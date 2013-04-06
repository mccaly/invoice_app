class RemoveAccountIdFromAccounts < ActiveRecord::Migration
  def up
    remove_column :accounts, :account_id
  end

  def down
    add_column :accounts, :account_id, :integer
  end
end
