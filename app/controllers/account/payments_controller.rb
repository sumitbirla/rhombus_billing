class Account::PaymentsController < Account::BaseController
  def index
    @payments = Payment.where(user_id: session[:user_id], customer: false).order(created_at: :desc).page(params[:page])
    if params[:t] == "1"
      @payments = @payments.where("amount > 0.0")
    elsif params[:t]  == "0"
      @payments = @payments.where("amount < 0.0")
    end
  end

  def show
    @payment = Payment.find_by(user_id: session[:user_id], id: params[:id])
  end
end
