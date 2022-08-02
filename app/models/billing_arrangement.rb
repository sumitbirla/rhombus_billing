# == Schema Information
#
# Table name: bill_billing_arrangements
#
#  id                           :bigint           not null, primary key
#  dropshipper_transaction_fee  :decimal(5, 2)    default(0.0), not null
#  invoice_seller               :boolean          default(FALSE), not null
#  percent_of_msrp              :decimal(5, 2)
#  seller_transaction_fee       :decimal(5, 2)    default(0.0), not null
#  seller_transaction_percent   :decimal(5, 2)
#  uses_seller_shipping_account :boolean          default(FALSE), not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  affiliate_id                 :integer          not null
#  seller_id                    :integer          not null
#
class BillingArrangement < ApplicationRecord
  self.table_name = "bill_billing_arrangements"

  belongs_to :affiliate
  belongs_to :seller, class_name: "Affiliate", foreign_key: :seller_id

  has_many :extra_properties, -> { order "sort, name" }, as: :extra_property, dependent: :destroy
  accepts_nested_attributes_for :extra_properties, reject_if: proc { |x| x['name'].blank? && x['value'].blank? }

  validates_presence_of :affiliate_id, :seller_id, :seller_transaction_fee, :dropshipper_transaction_fee
  validates_uniqueness_of :affiliate_id, scope: :seller_id, message: "Billing arrangement between selected parties already exists."

  after_save :set_negotiated_prices
  before_destroy :set_default_prices

  def to_s
    return "New Billing Arrangement" unless persisted?
    "#{affiliate}  <->  #{seller}"
  end


  def set_negotiated_prices
    if percent_of_msrp.nil?
      set_default_prices
    else
      sql = <<-EOF
				UPDATE store_affiliate_products ap
				JOIN store_products p ON ap.product_id = p.id
				SET ap.price = p.msrp * #{percent_of_msrp} / 100
				WHERE p.fulfiller_id = #{affiliate_id}
				AND ap.affiliate_id = #{seller_id};
      EOF

      ActiveRecord::Base.connection.execute(sql)
    end
  end


  def set_default_prices
    sql = <<-EOF
			UPDATE store_affiliate_products ap
			JOIN store_products p ON ap.product_id = p.id
			SET ap.price = p.reseller_price
			WHERE p.fulfiller_id = #{affiliate_id}
			AND ap.affiliate_id = #{seller_id};
    EOF

    ActiveRecord::Base.connection.execute(sql)
  end


  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end

end
