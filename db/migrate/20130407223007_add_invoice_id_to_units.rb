class AddInvoiceIdToUnits < ActiveRecord::Migration
  def change
  	add_column :units, :invoice_id, :integer
  end
end
