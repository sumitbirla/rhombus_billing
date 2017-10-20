class Admin::Billing::PaymentMethodsController < Admin::BaseController

  def index
    authorize PaymentMethod
    @payment_methods = PaymentMethod.includes(:user)
    
    respond_to do |format|
      format.html { @payment_methods = @payment_methods.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data PaymentMethod.to_csv(@payment_methods) }
    end
  end

  def show
    @payment_method = authorize PaymentMethod.find(params[:id])
  end

  def new
    @payment_method = authorize PaymentMethod.new(user_id: params[:user_id])
  end

  def create
    @payment_method = authorize PaymentMethod.new(payment_method_params)
    @payment_method.status = 'A'

    if @payment_method.save
      flash[:notice] = 'Payment Method was successfully created.'
      redirect_to action: 'index'
    else
      render 'new'
    end
  end
  
  def destroy
    pm = authorize PaymentMethod.find(params[:id])
    pm.destroy
    
    # if there is only one remaining payment_method, make it the default
    if PaymentMethod.where(user_id: pm.user_id).count == 1
      PaymentMethod.where(user_id: pm_user_id).update_all(default: true)
    end
    
    redirect_to action: 'index'
  end


  private

    def payment_method_params
      params.require(:payment_method).permit!
    end

end
