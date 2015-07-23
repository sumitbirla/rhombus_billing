# == Schema Information
#
# Table name: bill_payments
#
#  id                  :integer          not null, primary key
#  payable_id          :string(255)
#  payable_type        :string(255)      default("")
#  user_id             :integer
#  customer            :boolean          default(TRUE), not null
#  payment_method_id   :integer
#  amount              :decimal(10, 2)   not null
#  transaction_id      :string(255)
#  cc                  :boolean          default(FALSE), not null
#  cc_type             :string(255)
#  cc_cardholder_name  :string(255)
#  cc_number           :string(255)
#  cc_expiration_month :integer
#  cc_expiration_year  :integer
#  cc_code             :string(255)
#  memo                :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

require 'activemerchant'

class Payment < ActiveRecord::Base
  self.table_name = 'bill_payments'
  
  before_save :charge_card
  
  belongs_to :payable, polymorphic: true
  belongs_to :user
  belongs_to :payment_method

  validates_presence_of :payable_id, :payable_type, :amount
  validates_presence_of :cc_cardholder_name, :cc_number, :cc_expiration_month, :cc_expiration_year, :cc_code, if: :paid_with_card?
  
  def paid_with_card?
    cc
  end
  
  def self.to_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |pmt|
        csv << pmt.attributes.values_at(*column_names)
      end
    end
  end
  
  def charge_card
    return true unless cc
    
    active_gw = Cache.setting('eCommerce', 'Payment Gateway')
    
    if active_gw == 'Authorize.net'
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
          :login => Cache.setting('eCommerce', 'Authorize.Net Login ID'),
          :password => Cache.setting('eCommerce', 'Authorize.Net Transaction Key'),
          :test => false
      )
    elsif active_gw == 'Stripe'
      gateway = ActiveMerchant::Billing::StripeGateway.new(
          :login => Cache.setting('eCommerce', 'Stripe Secret Key')
      )  
    else
      raise "Payment gateway is not set up."
    end 
    
    credit_card = ActiveMerchant::Billing::CreditCard.new(
      :number             => cc_number,
      :verification_value => cc_code,
      :month              => cc_expiration_month,
      :year               => cc_expiration_year,
      :first_name         => cc_cardholder_name.split.first,
      :last_name          => cc_cardholder_name.split.last
    )
    
    purchase_options = {
      :order_id => payable_id,
      :customer => cc_cardholder_name,
    }

    response = gateway.purchase((amount*100).to_i, credit_card, purchase_options)
    if response.success?
      update_attributes({ 
        cc_number: credit_card.display_number, 
        cc_code: nil, 
        transaction_id: response.authorization
      })
    end
    
    errors.add :base, response.message
    response.success?
    
  end
  
end
