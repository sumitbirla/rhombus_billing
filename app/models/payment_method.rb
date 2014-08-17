# == Schema Information
#
# Table name: payment_methods
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  default                 :boolean          default(FALSE), not null
#  card_brand              :string(255)      default(""), not null
#  name                    :string(255)      not null
#  card_display            :string(255)      default(""), not null
#  cardholder_name         :string(255)      not null
#  expiration_month        :integer          not null
#  expiration_year         :integer          not null
#  billing_street1         :string(255)      not null
#  billing_street2         :string(255)
#  billing_city            :string(255)      not null
#  billing_state           :string(255)      not null
#  billing_zip             :string(255)      not null
#  billing_country         :string(255)      default(""), not null
#  encrypted_cc            :text             not null
#  iv                      :text             not null
#  status                  :string(255)      not null
#  last_transaction_result :string(255)
#  last_transaction_date   :datetime
#  bill_attempts           :integer          default(0), not null
#  created_at              :datetime
#  updated_at              :datetime
#

class PaymentMethod < ActiveRecord::Base
  self.table_name = 'bill_payment_methods'
  
  attr_accessor :number
  belongs_to :user
  has_many :payments
  validates_presence_of :user_id, :name, :card_brand, :cardholder_name, :expiration_month, :expiration_year

  def credit_card
    ActiveMerchant::Billing::CreditCard.new(
        :brand              => card_brand,
        :number             => @number,
        :verification_value => '1234',
        :month              => expiration_month,
        :year               => expiration_year,
        :first_name         => cardholder_name.split[0],
        :last_name          => cardholder_name.split[1]
    )
  end

  def card_valid?
    unless credit_card.valid?
      errors.add(:cc_number, "Credit card is not valid. #{credit_card.errors.full_messages.join('. ')}")
      return false
    end

    return true
  end

  def to_s
    card_brand + ' *' + card_display[-4, 4]
  end

  def self.CARD_BRANDS
    ['Visa', 'MasterCard', 'Discover', 'American Express' ]
  end

end
