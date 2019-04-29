class Account::PaymentMethodsController < Account::BaseController

  def index
    @payment_methods = PaymentMethod.where(user_id: session[:user_id]).order(created_at: :desc)
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)
    @payment_method.user_id = session[:user_id]
    @payment_method.status = 'A'
    
    # if this is only one payment_method, make it the default
    if PaymentMethod.where(user_id: session[:user_id]).count == 0
      @payment_method.default = true
    end
    
    @payment_method.save
    
    respond_to do |format|
      format.html do
        if @payment_method.errors.any?
          render 'new'
        else
          flash[:notice] =  'Payment method was successfully saved.'
          redirect_to action: 'index'
        end
      end
      format.js { render :layout => false }
    end
  end

  def destroy
    @payment_method = PaymentMethod.find_by(id: params[:id], user_id: session[:user_id])
    @payment_method.destroy
    
    # if there is only one remaining payment_method, make it the default
    if PaymentMethod.where(user_id: session[:user_id]).count == 1
      PaymentMethod.where(user_id: session[:user_id]).update_all(default: true)
    end
    
    respond_to do |format|
      format.html do
        flash[:notice] =  'Payment method has been removed.'
        redirect_to action: 'index'
      end
      format.js { render :layout => false }
    end
  end

  def primary
    PaymentMethod.where(user_id: session[:user_id]).update_all(default: false)
    PaymentMethod.where(user_id: session[:user_id], id: params[:id]).update_all(default: true)

    redirect_back(fallback_location: account_payment_methods)
  end


  private

  def payment_method_params
    params.require(:payment_method).permit(:cardholder_name, :number, :expiration_month, :expiration_year, :expiration,
                                           :billing_street1, :billing_street2, :billing_city, :billing_state,
                                           :billing_zip, :billing_country)
  end

end
