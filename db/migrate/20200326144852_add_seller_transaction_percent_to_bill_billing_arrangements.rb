class AddSellerTransactionPercentToBillBillingArrangements < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_billing_arrangements, :seller_transaction_percent, :decimal, precision: 5, scale: 2
  end
end
