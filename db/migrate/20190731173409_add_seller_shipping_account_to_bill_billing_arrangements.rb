class AddSellerShippingAccountToBillBillingArrangements < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_billing_arrangements, :uses_seller_shipping_account, :boolean, null: false, default: false, after: :seller_transaction_fee
  end
end
