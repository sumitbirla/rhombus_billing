# == Schema Information
#
# Table name: payments
#
#  id                :integer          not null, primary key
#  payable_id        :integer
#  payable_type      :string(255)      default("")
#  user_id           :integer          not null
#  payment_method_id :integer
#  amount            :decimal(10, 2)   not null
#  transaction_id    :string(255)
#  memo              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class Payment < ActiveRecord::Base
  self.table_name = 'bill_payments'
  
  belongs_to :payable, polymorphic: true
  belongs_to :user
  belongs_to :payment_method

  validates_presence_of :payable_id, :payable_type, :amount
end
