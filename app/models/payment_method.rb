# == Schema Information
#
# Table name: bill_payment_methods
#
#  id                      :integer          not null, primary key
#  bill_attempts           :integer          default(0), not null
#  billing_city            :string(255)      default("")
#  billing_country         :string(255)      default("")
#  billing_state           :string(255)      default("")
#  billing_street1         :string(255)      default("")
#  billing_street2         :string(255)
#  billing_zip             :string(255)      default("")
#  card_brand              :string(255)      default(""), not null
#  card_display            :string(255)      default(""), not null
#  cardholder_name         :string(255)      not null
#  default                 :boolean          default(FALSE), not null
#  encrypted_cc            :text(65535)      not null
#  expiration_month        :integer          not null
#  expiration_year         :integer          not null
#  iv                      :text(65535)      not null
#  last_transaction_date   :datetime
#  last_transaction_result :string(255)
#  status                  :string(255)      not null
#  created_at              :datetime
#  updated_at              :datetime
#  user_id                 :integer          not null
#
# Indexes
#
#  index_payment_methods_on_user_id  (user_id)
#

require 'activemerchant'
require 'credit_card_validations'
require 'openssl'
require 'base64'

class PaymentMethod < ActiveRecord::Base
  include PaymentGateway
  include Exportable

  self.table_name = 'bill_payment_methods'
  attr_accessor :number

  before_validation :set_brand
  before_save :encrypt_number

  belongs_to :user
  has_many :payments
  has_many :cc_transactions

  validates :number, presence: true, credit_card_number: true
  validates_presence_of :user_id, :card_brand, :cardholder_name, :expiration_month, :expiration_year

  def to_s
    (cardholder_name + " · " + card_brand.upcase + " " + card_display).html_safe
  end

  def self.CARD_BRANDS
    ['Visa', 'MasterCard', 'Discover', 'American Express']
  end

  def set_brand
    self.card_brand = CreditCardValidations::Detector.new(number).brand
  end

  def expiration
    "#{expiration_month}/#{expiration_year}"
  end

  def expiration=(str)
    mo, yr = str.split("/").map { |x| x.strip }
    return if mo.blank? || yr.blank?

    yr = "20" + yr if yr.length == 2
    self.expiration_month = mo.to_i
    self.expiration_year = yr.to_i
  end

  def encrypt_number
    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt
    cipher.key = IO.binread('/var/lib/rhombus.bin')

    self.iv = Base64.encode64(cipher.random_iv)
    self.encrypted_cc = Base64.encode64(cipher.update(number) + cipher.final)

    self.card_brand = CreditCardValidations::Detector.new(number).brand
    self.card_display = 'x-' + number[-4, 4]
  end

  def decrypt_number
    decipher = OpenSSL::Cipher::AES.new(256, :CBC)
    decipher.decrypt
    decipher.key = IO.binread('/var/lib/rhombus.bin')
    decipher.iv = Base64.decode64(iv)
    self.number = decipher.update(Base64.decode64(encrypted_cc)) + decipher.final
  end

  def charge(amount, cvv2 = nil)

    credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number => decrypt_number,
        :month => expiration_month,
        :year => expiration_year,
        :first_name => cardholder_name.split[0],
        :last_name => cardholder_name.split[1]
    )

    credit_card.verification_value = cvv2 unless cvv2.blank?

    purchase_options = {
        :billing_address => {
            :name => cardholder_name,
            :address1 => billing_street1,
            :address2 => billing_street2,
            :city => billing_city,
            :state => billing_state,
            :zip => billing_zip,
            :country => billing_country
        }}

    # active_gateway is defined in concerns
    response = active_gateway.purchase((amount * 100).to_i, credit_card, purchase_options)
    CcTransaction.create(
        payment_method_id: id,
        gateway: "stripe",
        action: "purchase",
        amount: amount,
        result: (response.success? ? "OK" : "FAIL"),
        data: response.to_yaml
    )

    # record status
    if response.success?
      update(bill_attempts: 0,
             last_transaction_date: DateTime.now,
             last_transaction_result: response.message,
             status: "A")
    else
      update(bill_attempts: bill_attempts + 1,
             last_transaction_date: DateTime.now,
             last_transaction_result: response.message,
             status: "D")
    end

    response
  end

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
