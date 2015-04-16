class ChangePayableIdInBillPayments < ActiveRecord::Migration
  def change
	change_column :bill_payments, :payable_id, :string
  end
end
