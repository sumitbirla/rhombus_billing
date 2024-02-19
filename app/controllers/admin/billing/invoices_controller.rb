class Admin::Billing::InvoicesController < Admin::BaseController

  def index
    authorize Invoice.new
    @invoices = Invoice.where(paid: params[:paid])
                    .order(post_date: :desc)
                    .paginate(page: params[:page], per_page: @per_page)
  end

  def new
    if params[:affiliate_id]
      @pending_payments = Payment.where(affiliate_id: params[:affiliate_id], invoice_id: nil)
                              .where.not(payable_type: :invoice)
    end

    @invoice = Invoice.new
    5.times { @invoice.payments.build }

    authorize @invoice
    render 'edit'
  end

  def create
    @invoice = authorize Invoice.new(invoice_params)

    unless params[:add_more_items].blank?
      count = params[:add_more_items].to_i - @invoice.items.length + 5
      count.times { @invoice.payments.build }
      return render 'edit'
    end

    if @invoice.save
      redirect_to action: 'show', id: @invoice.id, notice: 'Invoice was successfully created.'
    else
      5.times { @invoice.payments.build }
      render 'edit'
    end
  end

  def edit
    @invoice = authorize Invoice.find(params[:id])
    @pending_payments = Payment.where(invoice_id: @invoice.id)
                            .where.not(payable_type: :invoice)

    2.times { @invoice.payments.build }
  end

  def update
    @invoice = authorize Invoice.find(params[:id])
    item_count = @invoice.payments.length

    @invoice.assign_attributes(invoice_params)

    unless params[:add_more_items].blank?
      count = params[:add_more_items].to_i - item_count + 5
      count.times { @invoice.payments.build }
      return render 'edit'
    end

    if @invoice.save(validate: false)
      redirect_to action: 'show', id: @invoice.id, notice: 'Invoice was successfully updated.'
    else
      render 'edit'
    end
  end

  def show
    @invoice = authorize Invoice.find(params[:id])
  end

  def print
    @invoice = Invoice.find(params[:id])
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
    ret = system("wkhtmltopdf -q -s Letter #{urls} #{output_file}")

    #puts ">>>>>>>> " + urls

    unless File.exist?(output_file)
      flash[:error] = "Unable to generate PDF [Debug: #{$?}]"
      return redirect_back(fallback_location: admin_billing_invoices_path)
    end

    if params[:printer_id].blank?
      send_file output_file
    else
      printer = Printer.find(params[:printer_id])
      job = printer.print_file(output_file)
      flash[:info] = "Print job submitted to '#{printer.name} [#{printer.location}]'. CUPS JobID: #{job.id}"
      redirect_back(fallback_location: admin_billing_invoices_path)
    end
  end

  def email
    @invoice = Invoice.find(params[:invoice_id])

    EmailInvoiceJob.perform_later(@invoice.id, params[:email])
    @invoice.logs.create(user_id: session[:user_id], ip_address: request.remote_ip, event: 'emailed', data1: params[:email])

    flash[:info] = "Invoice ##{@invoice.id} has been emailed to #{params[:email]}"
    redirect_back(fallback_location: admin_billing_invoices_path)
  end

  def email_batch

    if params[:email_address].blank?
      flash[:error] = "Please specify an email address"
      return redirect_back(fallback_location: admin_billing_invoices_path)
    end

    if params[:invoice_id].length == 0
      flash[:error] = "Please invoices to email"
      return redirect_back(fallback_location: admin_billing_invoices_path)
    end

    begin
      InvoiceMailer.batch(params[:invoice_id], session[:user_id], params[:email_address], request.remote_ip).deliver_now
      flash[:success] = "#{params[:invoice_id].length} invoice(s) were mailed to '#{params[:email_address]}'"
    rescue => e
      flash[:error] = e.message
    end

    redirect_back(fallback_location: admin_billing_invoices_path)
  end


  def update_status_batch
    authorize Invoice, :update?
    list = Invoice.where(id: params[:invoice_id])

    list.each do |invoice|
      invoice.update(paid: params[:paid] == "true")
      #log
    end

    flash[:info] = "#{list.length} invoices updated"
    redirect_back(fallback_location: admin_billing_invoices_path)
  end

  def destroy
    @invoice = authorize Invoice.find(params[:id])

    Payment.where(invoice_id: @invoice.id).update_all(invoice_id: nil)
    @invoice.destroy

    flash.now[:success] = "Invoice ##{@invoice.id} has been deleted"
    redirect_back(fallback_location: admin_billing_invoices_path)
  end


  private

  def invoice_params
    params.require(:invoice).permit!
  end

end
