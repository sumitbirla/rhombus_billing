class Admin::Billing::InvoicesController < Admin::BaseController
  
  def index
    authorize Invoice.new
    @invoices = Invoice.where(paid: params[:paid])
                       .order(post_date: :desc)
                       .paginate(page: params[:page], per_page: @per_page)
  end
  
  def new
    if params[:shipment_id]
      s = Shipment.find(params[:shipment_id])
      @invoice = s.order.invoices.build(affiliate_id: s.order.affiliate_id, 
                                        amount: s.invoice_amount, 
                                        post_date: Date.today, 
                                        due_date: Date.today + 1.month, 
                                        from_affiliate_id: 280)
      
      s.items.each do |item|
        next if item.product.nil?  # should never happen, only here for bad historical data (i.e. product was deleted from DB)
        @invoice.items.build(group: s.to_s, 
                            item_number: item.order_item.item_number,
                            item_description: item.order_item.item_description,
                            unit_price: item.order_item.unit_price,
                            quantity: item.quantity)
      end
      
      @invoice.items.build(group: s.to_s, item_number: 'Tax', item_description: '-', unit_price: s.order.tax_amount * -1, quantity: 1) if s.order.tax_amount > 0
      @invoice.items.build(group: s.to_s, item_number: 'Discount', item_description: '-', unit_price: s.order.discount_amount * -1, quantity: 1) if s.order.discount_amount > 0
      @invoice.items.build(group: s.to_s, item_number: 'Credit', item_description: '-', unit_price: s.order.credit_applied * -1, quantity: 1) if s.order.credit_applied > 0
      @invoice.items.build(group: s.to_s, item_number: 'Shipping', item_description: "#{s.carrier} #{s.ship_method}", unit_price: s.ship_cost, quantity: 1) if (s.ship_cost && s.ship_cost > 0)
    else
      @invoice = Invoice.new
    end
    
    authorize @invoice
    
    5.times { @invoice.items.build }
    render 'edit'
  end

  def create
    @invoice = authorize Invoice.new(invoice_params)
    
    unless params[:add_more_items].blank?
      count = params[:add_more_items].to_i - @invoice.items.length + 5 
      count.times { @invoice.items.build }
      return render 'edit'
    end
  
    if @invoice.save
      redirect_to action: 'show', id: @invoice.id, notice: 'Invoice was successfully created.'
    else
      5.times { @invoice.items.build }
      render 'edit'
    end
  end

  def show
    @invoice = authorize Invoice.find(params[:id])
  end
  
  def print
    @invoice = Invoice.find(params[:id])
    authorize @invoice, :show?
    render 'print', layout: nil
  end
  
  def print_batch
    authorize Invoice, :show?
    
    urls = ''
    token = Cache.setting(Rails.configuration.domain_id, :system, 'Security Token')
    website_url = Cache.setting(Rails.configuration.domain_id, :system, 'Website URL')
    
    Invoice.where(id: params[:invoice_id]).each do |inv|
      digest = Digest::MD5.hexdigest(inv.id.to_s + token) 
      urls += " " + website_url + print_admin_billing_invoice_path(inv, digest: digest) 
      
      # LOG HERE
      inv.logs.create(timestamp: Time.now, 
                      user_id: session[:user_id], 
                      ip_address: request.remote_ip, 
                      event: :printed, 
                      data1: params[:printer_id].presence || 'PDF download')
    end
    
    output_file = "/tmp/#{SecureRandom.hex(6)}.pdf"
    ret = system("wkhtmltopdf -q #{urls} #{output_file}")
    
    unless File.exists?(output_file)
      flash[:error] = "Unable to generate PDF [Debug: #{$?}]"
      return redirect_to :back
    end
    
    if params[:printer_id].blank?
      send_file output_file
    else
      printer = Printer.find(params[:printer_id])
      job = printer.print_file(output_file)
      flash[:info] = "Print job submitted to '#{printer.name} [#{printer.location}]'. CUPS JobID: #{job.id}"
      redirect_to :back
    end
  end
  
  def email
    @invoice = Invoice.find(params[:invoice_id])
    
    EmailInvoiceJob.perform_later(@invoice.id, params[:email])
    @invoice.logs.create(user_id: session[:user_id], ip_address: request.remote_ip, event: 'emailed', data1: params[:email])
    
    flash[:info] = "Invoice ##{@invoice.id} has been emailed to #{params[:email]}"
    redirect_to :back
  end
  
  def email_batch
    
    if params[:email_address].blank?
      flash[:error] = "Please specify an email address"
      return redirect_to :back
    end
    
    if params[:invoice_id].length == 0
      flash[:error] = "Please invoices to email"
      return redirect_to :back
    end
    
    begin
      InvoiceMailer.batch(params[:invoice_id], session[:user_id], params[:email_address], request.remote_ip).deliver_now
      flash[:success] = "#{params[:invoice_id].length} invoice(s) were mailed to '#{params[:email_address]}'"
    rescue => e
      flash[:error] = e.message
    end
    
    redirect_to :back
  end

  def edit
    @invoice = authorize Invoice.find(params[:id])
    2.times { @invoice.items.build }
  end

  def update
    @invoice = authorize Invoice.find(params[:id])
    item_count = @invoice.items.length

    @invoice.assign_attributes(invoice_params)
    
    unless params[:add_more_items].blank?
      count = params[:add_more_items].to_i - item_count + 5 
      count.times { @invoice.items.build }
      return render 'edit'
    end

    if @invoice.save(validate: false)
      redirect_to action: 'show', id: @invoice.id, notice: 'Invoice was successfully updated.'
    else
      render 'edit'
    end
  end
  
  def update_status_batch
    authorize Invoice, :update?
    list = Invoice.where(id: params[:invoice_id])
    
    list.each do |invoice|
      invoice.update(paid: params[:paid] == "true")
      #log
    end
    
    flash[:info] = "#{list.length} invoices updated"
    redirect_to :back
  end

  def destroy
    @invoice = authorize Invoice.find(params[:id])
    @invoice.destroy
    
    flash.now[:success] = "Invoice ##{@invoice.id} has been deleted"
    redirect_to :back
  end
  
  
  private
  
    def invoice_params
      params.require(:invoice).permit!
    end
  
end
