class Admin::Billing::InvoicesController < Admin::BaseController
  
  def index
    @invoices = Invoice.where(paid: params[:paid])
                       .order(created_at: :desc)
                       .paginate(page: params[:page], per_page: @per_page)
  end
  
end
