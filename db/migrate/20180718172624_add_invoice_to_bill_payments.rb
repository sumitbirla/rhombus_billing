class AddInvoiceToBillPayments < ActiveRecord::Migration
  def change
    add_column :bill_payments, :invoice_id, :integer
  end
end
