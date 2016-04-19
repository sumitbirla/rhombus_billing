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
  validates_presence_of :cc_cardholder_name, :cc_number, :cc_expiration_month, :cc_expiration_year, :cc_code, if: :charge_manual_entry?
  
  
  def charge_manual_entry?
    cc && payment_method_id.nil?
  end
  
  def charge_saved_card?
    cc && payment_method_id
  end
  
  def self.to_csv
    CSV.generate do |csv|
      cols = column_names - ['payable_id', 'payable_type', 'customer', 'payment_method_id']
      csv << cols
      all.each do |pmt|
        csv << pmt.attributes.values_at(*cols)
      end
    end
  end
  
  def charge_card
    return true unless cc
    
    # saved credit card selected?
    unless payment_method_id.nil?
      pm = PaymentMethod.find(payment_method_id)
      response = pm.charge(amount)
      this.transaction_id = response.authorization
      
      errors.add :base, response.message
      return response.success?
    end
    
    # manual entry
    active_gw = Cache.setting('eCommerce', 'Payment Gateway')
    
    if active_gw == 'Authorize.net'
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
          :login => Cache.setting(Rails.configuration.domain_id, 'eCommerce', 'Authorize.Net Login ID'),
          :password => Cache.setting(Rails.configuration.domain_id, 'eCommerce', 'Authorize.Net Transaction Key'),
          :test => false
      )
    elsif active_gw == 'Stripe'
      gateway = ActiveMerchant::Billing::StripeGateway.new(
          :login => Cache.setting(Rails.configuration.domain_id, 'eCommerce', 'Stripe Secret Key')
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
  
  
  def refund(amount)

    gateway = ActiveMerchant::Billing::StripeGateway.new(
      :login => Cache.setting(Rails.configuration.domain_id, 'eCommerce', 'Stripe Secret Key')
    )
    
    # process refund
    response = gateway.refund((amount * 100).to_i, transaction_id)
    CcTransaction.create(
      payment_method_id: id,
      gateway: "stripe",
      action: "refund",
      amount: amount,
      result: (response.success? ? "OK" : "FAIL"),
      data: response.to_yaml
    )
    
    # create payment record for refund
    if response.success?
      pmt = this.dup
      pmt.assign_attributes({
        amount: amount * -1.0,
        memo: "Refund",
        transaction_id: response.authorization
      })
      pmt.save
    end
    
    response  
  end
  
end
