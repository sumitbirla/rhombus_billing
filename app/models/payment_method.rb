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
require 'credit_card_validations'
require 'openssl'
require 'base64'

class PaymentMethod < ActiveRecord::Base
  
  self.table_name = 'bill_payment_methods'
  attr_accessor :number
  
  before_validation :set_brand
  before_save :encrypt_number
  
  belongs_to :user
  has_many :payments
  
  validates :number, presence: true, credit_card_number: true
  validates_presence_of :user_id, :card_brand, :cardholder_name, :expiration_month, :expiration_year

  def self.CARD_BRANDS
    ['Visa', 'MasterCard', 'Discover', 'American Express' ]
  end
  
  def set_brand
    self.card_brand = CreditCardValidations::Detector.new(number).brand
  end
  
  def encrypt_number  
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt
    cipher.key = IO.binread('/var/lib/rhombus.bin')
    
    self.iv = Base64.encode64(cipher.random_iv)
    self.encrypted_cc = Base64.encode64(cipher.update(number) + cipher.final)
    
    self.card_display = 'x-' + number[-4, 4]
  end
  
  def to_s
    card_brand + ' ' + card_display
  end
  
end
