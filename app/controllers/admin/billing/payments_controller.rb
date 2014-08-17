class Admin::Billing::PaymentsController < Admin::BaseController
  
  def index
    @payments = Payment.page(params[:page]).order('created_at DESC')
  end

  def new
    @payment = Payment.new memo: 'New Payment'
    render 'edit'
  end

  def create
    @payment = Payment.new(payment_params)

    if @payment.save
      flash[:notice] =  'Payment was successfully created.'
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def update
    @payment = Payment.find(params[:id])

    if @payment.update(payment_params)
      flash[:notice] =  'Payment was successfully updated.'
       redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @payment.destroy

    flash[:notice] = 'Payment has been deleted.'
    redirect_to action: 'index'
  end


  private

    def payment_params
      params.require(:payment).permit(:user_id, :order_id, :user_package_id, :transaction_id, :memo, :amount)
    end
  
end
