class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :bill_invoices do |t|
      t.integer :invoiceable_id, null: false
      t.string :invoiceable_type, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.date :due_date
      t.boolean :paid, null: false, default: false
      t.text :note

      t.timestamps null: false
    end
  end
end
