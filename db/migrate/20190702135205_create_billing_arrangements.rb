class CreateBillingArrangements < ActiveRecord::Migration[5.2]
  def change
    create_table :bill_billing_arrangements do |t|
      t.integer :affiliate_id, null: false
      t.integer :seller_id, null: false
      t.decimal :dropshipper_transaction_fee, precision: 5, scale: 2, null: false, default: 0.0
      t.decimal :seller_transaction_fee, precision: 5, scale: 2, null: false, default: 0.0

      t.timestamps
    end
  end
end
