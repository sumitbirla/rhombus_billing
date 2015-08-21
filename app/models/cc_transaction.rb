class CcTransaction < ActiveRecord::Base
  self.table_name = "bill_cc_transactions"
  belongs_to :payment_method
  validates_presence_of :payment_method_id, :gateway, :action, :amount, :result
end
