# == Schema Information
#
# Table name: bill_cc_transactions
#
#  id                :integer          not null, primary key
#  action            :string(255)      not null
#  amount            :decimal(8, 2)    not null
#  data              :text(65535)
#  gateway           :string(255)      not null
#  result            :string(255)      not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  payment_method_id :integer
#
# Indexes
#
#  index_bill_cc_transactions_on_payment_method_id  (payment_method_id)
#

class CcTransaction < ActiveRecord::Base
  include Exportable

  self.table_name = "bill_cc_transactions"
  belongs_to :payment_method
  validates_presence_of :gateway, :action, :amount, :result

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
