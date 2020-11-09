module PaymentGateway
  extend ActiveSupport::Concern

  def active_gateway(domain = nil)
    domain_id = domain || Rails.configuration.domain_id
    active_gw = Cache.setting(domain_id, 'eCommerce', 'Payment Gateway')

    if active_gw == 'Authorize.net'
      gateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
          :login => Cache.setting(domain_id, 'eCommerce', 'Authorize.Net Login ID'),
          :password => Cache.setting(domain_id, 'eCommerce', 'Authorize.Net Transaction Key'),
          :test => false
      )
    elsif active_gw == 'Stripe'
      gateway = ActiveMerchant::Billing::StripeGateway.new(
          :login => Cache.setting(domain_id, 'eCommerce', 'Stripe Secret Key')
      )
    else
      raise "Payment gateway is not set up."
    end

    gateway
  end

end