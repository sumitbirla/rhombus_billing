class AddCustomerToBillPayments < ActiveRecord::Migration
  def change
    add_column :bill_payments, :customer, :boolean, null: false, default: true
  end
end
