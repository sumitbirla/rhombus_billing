class InvoiceMailer < ActionMailer::Base
  
  def batch(invoice_ids, user_id, email_address, ip_address)
    
    @invoices = Invoice.where(id: invoice_ids)
    
    urls = ''
    token = Cache.setting(Rails.configuration.domain_id, :system, 'Security Token')
    website_url = Cache.setting(Rails.configuration.domain_id, :system, 'Website URL')
    
    @invoices.each do |inv|
      digest = Digest::MD5.hexdigest(inv.id.to_s + token) 
      urls += " " + website_url + print_admin_billing_invoice_path(inv, digest: digest) 
    end
    
    output_file = "/tmp/#{SecureRandom.hex(6)}.pdf"
    ret = system("wkhtmltopdf -q #{urls} #{output_file}")
    
    raise "Could not generate PDF" unless File.exists?(output_file)
  
    from_name = Cache.setting(Rails.configuration.domain_id, :system, 'From Email Name')
    from_email = Cache.setting(Rails.configuration.domain_id, :system, 'From Email Address')

    options = {
        address: '10.0.7.1', #Cache.setting(Rails.configuration.domain_id, :system, 'SMTP Server'),
        openssl_verify_mode: 'none'
    }
    
    attachments['Invoices.pdf'] = File.read(output_file)
    
    mail(from: "#{from_name} <#{from_email}>",
         to: email_address,
         subject: "Invoice attached (#{@invoices.length})",
         delivery_method_options: options)
         
    File.delete(output_file)
    
    # DO LOGGING
    @invoices.each do |inv|
      inv.logs.create(timestamp: Time.now, 
                      user_id: user_id, 
                      ip_address: ip_address, 
                      event: :emailed, 
                      data1: email_address)
    end
  end
  
end
