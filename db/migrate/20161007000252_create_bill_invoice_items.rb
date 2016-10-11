class CreateBillInvoiceItems < ActiveRecord::Migration
  def change
    create_table :bill_invoice_items do |t|
      t.integer :invoice_id, null: false
      t.string :item_number, null: false
      t.string :item_description, null: false
      t.decimal :unit_price, scale: 4, precision: 10, null: false
      t.integer :quantity, null: false
    end
  end
end
