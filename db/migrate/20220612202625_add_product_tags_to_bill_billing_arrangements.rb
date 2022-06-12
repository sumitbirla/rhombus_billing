class AddProductTagsToBillBillingArrangements < ActiveRecord::Migration[6.1]
  def change
    add_column :bill_billing_arrangements, :product_tags, :string, after: :invoice_seller
  end
end
