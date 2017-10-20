class CreditMemo < ActiveRecord::Base
  self.table_name = 'bill_credit_memos'
  
  belongs_to :user
  belongs_to :affiliate
  
  validates_presence_of :amount, :description, :used
  validates_presence_of :user_id, unless: ->(cm){cm.affiliate_id.present?}
  validates_presence_of :affiliate_id, unless: ->(cm){cm.user_id.present?}
  
  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end