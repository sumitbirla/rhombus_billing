class AddInvoiceSellerToBillBillingArrangements < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_billing_arrangements, :invoice_seller, :boolean, null: false, default: false
  end
end
