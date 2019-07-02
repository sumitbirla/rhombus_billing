class Admin::Billing::BillingArrangementsController < Admin::BaseController
  
	def index
    authorize BillingArrangement.new
    @billing_arrangements = BillingArrangement.includes(:affiliate, :seller)
    
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
      redirect_to action: 'index', notice: 'BillingArrangement was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @billing_arrangement = authorize BillingArrangement.includes(:details, [details: :service_type]).find(params[:id])
  end

  def edit
    @billing_arrangement = authorize BillingArrangement.find(params[:id])
  end

  def update
    @billing_arrangement = authorize BillingArrangement.find(params[:id])
    
    if @billing_arrangement.update(billing_arrangement_params)
      redirect_to action: 'index', notice: 'Billing Arrangement was successfully updated.'
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
	
	

  private
  
    def billing_arrangement_params
      params.require(:billing_arrangement).permit!
    end
		
end
