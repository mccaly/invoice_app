class AddContactDetailsToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :contact_name, :string
    add_column :accounts, :contact_email, :string
    add_column :accounts, :contact_company, :sting
  end
end
