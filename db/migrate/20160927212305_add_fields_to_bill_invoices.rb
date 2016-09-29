class AddFieldsToBillInvoices < ActiveRecord::Migration
  def change
    add_column :bill_invoices, :user_id, :integer
    add_column :bill_invoices, :affiliate_id, :integer
	add_column :bill_payments, :affiliate_id, :integer
  end
end
