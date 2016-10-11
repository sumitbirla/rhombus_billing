class Admin::Billing::InvoicesController < Admin::BaseController
  
  def index
    @invoices = Invoice.where(paid: params[:paid])
                       .order(post_date: :desc)
                       .paginate(page: params[:page], per_page: @per_page)
  end
  
  def new
    @invoice = Invoice.new
    5.times { @invoice.items.build }
    
    render 'edit'
  end

  def create
    @invoice = Invoice.new(invoice_params)
    
    unless params[:add_more_items].blank?
      count = params[:add_more_items].to_i - @invoice.items.length + 5 
      count.times { @invoice.items.build }
      return render 'edit'
    end
  
    if @invoice.save
      redirect_to action: 'index', notice: 'Invoice was successfully created.'
    else
      5.times { @invoice.items.build }
      render 'edit'
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
  end

  def edit
    @invoice = Invoice.find(params[:id])
    2.times { @invoice.items.build }
  end

  def update
    @invoice = Invoice.find(params[:id])
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

  def destroy
    @invoice = Invoice.find(params[:id])
    @invoice.destroy
    redirect_to action: 'index', notice: 'Invoice has been deleted.'
  end
  
  
  private
  
    def invoice_params
      params.require(:invoice).permit!
    end
  
end
