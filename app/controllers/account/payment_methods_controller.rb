require 'openssl'
require 'base64'


class Account::PaymentMethodsController < Account::BaseController

  def index
    @payment_methods = PaymentMethod.where(user_id: session[:user_id]).order('created_at DESC')
  end

  def new
    @payment_method = PaymentMethod.new name: 'New payment_method'
  end

  def create
    @payment_method = PaymentMethod.new(payment_method_params)

    return render 'new' unless @payment_method.card_valid?

    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    cipher.encrypt

    cipher.key = IO.binread('/var/lib/rhombus.bin')
    iv = cipher.random_iv

    @payment_method.card_display = @payment_method.credit_card.display_number
    @payment_method.iv = Base64.encode64(iv)
    @payment_method.encrypted_cc = Base64.encode64(cipher.update(@payment_method.number) + cipher.final)
    @payment_method.status = 'A'
    @payment_method.user_id = session[:user_id]

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
    redirect_to action: 'index'
  end

  def primary
    PaymentMethod.where(user_id: session[:user_id]).update_all(default: false)
    PaymentMethod.where(user_id: session[:user_id], id: params[:id]).update_all(default: true)

    redirect_to :back
  end


  private

  def payment_method_params
    params.require(:payment_method).permit(:name, :card_brand, :cardholder_name, :number, :expiration_month, :expiration_year,
                                           :billing_street1, :billing_street2, :billing_city, :billing_state,
                                           :billing_zip, :billing_country)
  end

end
