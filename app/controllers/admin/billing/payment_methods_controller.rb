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

    return render 'new' unless @payment_method.card_valid?
    @payment_method.status = 'A'

    if @payment_method.save
      flash[:notice] = 'Payment Method was successfully created.'
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  def edit
    @payment_method = PaymentMethod.find(params[:id])
  end

  def update
    @payment_method = PaymentMethod.find(params[:id])

    if @payment_method.update(payment_method_params)
      flash[:notice] = 'Payment Method was successfully updated.'
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @payment_method = PaymentMethod.find(params[:id])
    @payment_method.destroy

    flash[:notice] = 'Payment Method has been deleted.'
    redirect_to action: 'index'
  end


  def details
    @payment_method = PaymentMethod.find(params[:id])
  end


  private

    def payment_method_params
      params.require(:payment_method).permit(:user_id, :default, :card_brand, :cardholder_name, :number, :expiration_month,
                    :expiration_year, :billing_street1, :billing_street2, :billing_city, :billing_state, :billing_zip,
                    :billing_country, :bill_attempts, :status)
    end

end
