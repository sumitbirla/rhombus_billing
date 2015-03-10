class AddCcFieldsToBillPayments < ActiveRecord::Migration
  def change
    add_column :bill_payments, :cc, :boolean, null: false, default: false
    add_column :bill_payments, :cc_type, :string
    add_column :bill_payments, :cc_cardholder_name, :string
    add_column :bill_payments, :cc_number, :string
    add_column :bill_payments, :cc_expiration_month, :integer
    add_column :bill_payments, :cc_expiration_year, :integer
    add_column :bill_payments, :cc_code, :string
  end
end
