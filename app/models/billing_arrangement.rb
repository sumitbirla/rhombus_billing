class BillingArrangement < ApplicationRecord
	self.table_name = "bill_billing_arrangements"

	belongs_to :affiliate
	belongs_to :seller, class_name: "Affiliate", foreign_key: :seller_id

	validates_presence_of :affiliate_id, :seller_id, :seller_transaction_fee, :dropshipper_transaction_fee

	def to_s
		return "New Billing Arrangement" unless persisted?
		"#{affiliate}  <->  #{seller}"
	end
	
  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
	
end
