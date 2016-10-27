class Admin::Billing::InvoicesController < Admin::BaseController
  
  def index
    @invoices = Invoice.where(paid: params[:paid])
                       .order(post_date: :desc)
                       .paginate(page: params[:page], per_page: @per_page)
  end
  
  def new
    if params[:shipment_id]
      s = Shipment.find(params[:shipment_id])
      @invoice = s.order.invoices.build(affiliate_id: s.order.affiliate_id, amount: s.invoice_amount, post_date: Date.today)
      
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
      @invoice.items.build(group: s.to_s, item_number: 'Shipping', item_description: "#{carrier} #{ship_method}", unit_price: s.ship_cost, quantity: 1) if (s.ship_cost && s.ship_cost > 0)
    else
      @invoice = Invoice.new
    end
    
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
      redirect_to action: 'index', paid: false, notice: 'Invoice was successfully created.'
    else
      5.times { @invoice.items.build }
      render 'edit'
    end
  end

  def show
    @invoice = Invoice.find(params[:id])
  end
  
  def print
    @invoice = Invoice.find(params[:id])
    render 'print', layout: nil
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
