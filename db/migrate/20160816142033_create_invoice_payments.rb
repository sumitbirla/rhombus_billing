class CreateInvoicePayments < ActiveRecord::Migration
  def change
    create_table :bill_invoice_payments do |t|
      t.references :invoice, index: true
      t.references :payment, index: true
    end
  end
end
