class Account::PaymentsController < Account::BaseController
  def index
    @payments = Payment.where(user_id: session[:user_id]).order(created_at: :desc).page(params[:page])
  end

  def show
    @payment = Payment.find_by(user_id: session[:user_id], id: params[:id])
  end
end
