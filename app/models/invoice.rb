class Invoice < ActiveRecord::Base
  self.table_name = 'bill_invoices'
  belongs_to :invoiceable, polymorphic: true
end
