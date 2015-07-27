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
    
    if @payment_method.save
      flash[:notice] = 'Payment Method was successfully created.'
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def destroy
    @payment_method = PaymentMethod.find_by(id: params[:id], user_id: session[:user_id])
    @payment_method.destroy
    
    # if there is only one remaining payment_method, make it the default
    if PaymentMethod.where(user_id: session[:user_id]).count == 1
      PaymentMethod.where(user_id: session[:user_id]).update_all(default: true)
    end
    
    redirect_to action: 'index'
  end

  def primary
    PaymentMethod.where(user_id: session[:user_id]).update_all(default: false)
    PaymentMethod.where(user_id: session[:user_id], id: params[:id]).update_all(default: true)

    redirect_to :back
  end


  private

  def payment_method_params
    params.require(:payment_method).permit(:cardholder_name, :number, :expiration_month, :expiration_year,
                                           :billing_street1, :billing_street2, :billing_city, :billing_state,
                                           :billing_zip, :billing_country)
  end

end
