class AddPercentOfMsrpToBillingArrangements < ActiveRecord::Migration[5.2]
  def change
    add_column :bill_billing_arrangements, :percent_of_msrp, :decimal, precision: 5, scale: 2, before: :created_at
  end
end
