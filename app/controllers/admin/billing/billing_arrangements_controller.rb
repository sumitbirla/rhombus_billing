class Admin::Billing::BillingArrangementsController < Admin::BaseController
  
	def index
    authorize BillingArrangement.new
    @billing_arrangements = BillingArrangement.includes(:affiliate, :seller).order(created_at: :desc)
    
    respond_to do |format|
      format.html { @billing_arrangements = @billing_arrangements.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data BillingArrangement.to_csv(@billing_arrangements) }
    end
  end

  def new
    @billing_arrangement = authorize BillingArrangement.new
    render 'edit'
  end

  def create
    @billing_arrangement = authorize BillingArrangement.new(billing_arrangement_params)
    
    if @billing_arrangement.save
      redirect_to action: :show, id: @billing_arrangement.id
    else
      render 'edit'
    end
  end

  def show
    @billing_arrangement = authorize BillingArrangement.find(params[:id])
  end

  def edit
    @billing_arrangement = authorize BillingArrangement.find(params[:id])
  end

  def update
    @billing_arrangement = authorize BillingArrangement.find(params[:id])
    
    if @billing_arrangement.update(billing_arrangement_params)
      redirect_to action: :show, id: @billing_arrangement.id
    else
      render 'edit'
    end
  end

  def destroy
    @billing_arrangement = authorize BillingArrangement.find(params[:id])
    @billing_arrangement.destroy
		
		flash[:notice] = "Billing Arrangement has been deleted."
    redirect_back fallback_location: { action: 'index' } 
  end
	
	def update_prices
		@billing_arrangement = BillingArrangement.find(params[:id])
		
	  ap_list = AffiliateProduct.joins(:product)
	                            .where(affiliate_id: @billing_arrangement.seller_id)
	                            .where("store_products.fulfiller_id = ?", @billing_arrangement.affiliate_id)
		
		if @billing_arrangement.percent_of_msrp
			count = ap_list.update_all("store_affiliate_products.price = store_products.msrp * #{@billing_arrangement.percent_of_msrp / 100.0}")
		else
			count = ap_list.update_all("store_affiliate_products.price = store_products.reseller_price")
		end
		
		flash[:info] = "Pricing updated."
		redirect_to action: :show, id: @billing_arrangement.id
	end

  private
  
    def billing_arrangement_params
      params.require(:billing_arrangement).permit!
    end
		
end
