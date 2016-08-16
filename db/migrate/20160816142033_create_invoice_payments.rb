class CreateInvoicePayments < ActiveRecord::Migration
  def change
    create_table :bill_invoices_payments do |t|
      t.references :invoice, index: true
      t.references :payment, index: true
    end
  end
end
