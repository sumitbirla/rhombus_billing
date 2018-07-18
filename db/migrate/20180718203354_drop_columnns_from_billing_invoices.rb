class DropColumnnsFromBillingInvoices < ActiveRecord::Migration
  def change
    remove_column :bill_invoices, :invoiceable_id
    remove_column :bill_invoices, :invoiceable_type
  end
end
