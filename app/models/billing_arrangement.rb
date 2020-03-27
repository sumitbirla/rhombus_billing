class BillingArrangement < ApplicationRecord
	self.table_name = "bill_billing_arrangements"

	belongs_to :affiliate
	belongs_to :seller, class_name: "Affiliate", foreign_key: :seller_id

	validates_presence_of :affiliate_id, :seller_id, :seller_transaction_fee, :dropshipper_transaction_fee
	validates_uniqueness_of :affiliate_id, scope: :seller_id, message: "Billing arrangement between selected parties already exists."

	def to_s
		return "New Billing Arrangement" unless persisted?
		"#{affiliate}  <->  #{seller}"
	end
	
  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
	
end
