class EmailInvoiceJob < ActiveJob::Base
  queue_as :default

  def perform(invoice_id, email, user_id)

    Mail.defaults do
      delivery_method :smtp, { :enable_starttls_auto => false  }
    end
    
    token = Cache.setting(Rails.configuration.domain_id, :system, 'Security Token')
    website_url = Cache.setting(Rails.configuration.domain_id, :system, 'Website URL')
    
    invoice = Invoice.find(invoice_id)
    digest = Digest::MD5.hexdigest(invoice_id.to_s + token) 
    url = website_url + "/admin/billing/invoices/#{invoice.id}/print?digest=#{digest}" 
      
    output_file = Rails.root.join('tmp', SecureRandom.hex(6) + ".pdf")
    system "wkhtmltopdf #{url} #{output_file}"
    
    Mail.deliver do
      from      Cache.setting(Rails.configuration.domain_id, :system, 'From Email Address')
      to        shipment.order.notify_email
      subject   "Invoice for #{o.external_order_id.blank? ? "order ##{o.id}" : o.external_order_id}"
      body      "Invoice attached:\n\n"
      add_file  output_file
    end
    
    File.delete(output_file)
    Invoice.logs.create(user_id: user_id, event: :emailed, data1: email)
    
  end
end
