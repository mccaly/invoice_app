class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.string :name
      t.string :number
      t.timestamp :date_begin
      t.timestamp :date_end
      t.string :billing_cycle
      t.integer :amount

      t.timestamps
    end
  end
end
