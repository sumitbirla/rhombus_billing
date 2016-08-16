# == Schema Information
#
# Table name: bill_cc_transactions
#
#  id                :integer          not null, primary key
#  payment_method_id :integer
#  gateway           :string(255)      not null
#  action            :string(255)      not null
#  amount            :decimal(8, 2)    not null
#  result            :string(255)      not null
#  data              :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class CcTransaction < ActiveRecord::Base
  include Exportable
  
  self.table_name = "bill_cc_transactions"
  belongs_to :payment_method
  validates_presence_of :gateway, :action, :amount, :result
end
