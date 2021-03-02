# == Schema Information
#
# Table name: bill_credit_memos
#
#  id           :integer          not null, primary key
#  amount       :decimal(10, 2)   not null
#  description  :string(255)      not null
#  used         :decimal(10, 2)   not null
#  created_at   :datetime
#  updated_at   :datetime
#  affiliate_id :integer
#  user_id      :integer
#
class CreditMemo < ActiveRecord::Base
  self.table_name = 'bill_credit_memos'

  belongs_to :user
  belongs_to :affiliate

  validates_presence_of :amount, :description, :used
  validates_presence_of :user_id, unless: ->(cm) { cm.affiliate_id.present? }
  validates_presence_of :affiliate_id, unless: ->(cm) { cm.user_id.present? }

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
