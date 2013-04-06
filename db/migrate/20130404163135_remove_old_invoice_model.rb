class RemoveOldInvoiceModel < ActiveRecord::Migration
  def up
  	drop_table :invoices
  end

  def down
  end
end
