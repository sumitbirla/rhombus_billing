class Admin::Billing::PaymentMethodsController < Admin::BaseController

  def index
    @payment_methods = PaymentMethod.includes(:user).page(params[:page])
  end

  def show
    @payment_method = PaymentMethod.find(params[:id])
  end

  def new
    @payment_method = PaymentMethod.new
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)
    @payment_method.status = 'A'

    if @payment_method.save
      flash[:notice] = 'Payment Method was successfully created.'
      redirect_to action: 'index'
    else
      render 'new'
    end
  end


  private

    def payment_method_params
      params.require(:payment_method).permit(:user_id, :default, :card_brand, :cardholder_name, :number, :expiration_month,
                    :expiration_year, :billing_street1, :billing_street2, :billing_city, :billing_state, :billing_zip,
                    :billing_country, :bill_attempts, :status)
    end

end
