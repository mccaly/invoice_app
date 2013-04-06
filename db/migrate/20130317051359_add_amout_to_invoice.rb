httclass AddAmoutToInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :amount, :integer
  end
end
