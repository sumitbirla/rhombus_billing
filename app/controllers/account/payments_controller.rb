class Account::PaymentsController < Account::BaseController
  def index
    @payments = Payment.where(user_id: session[:user_id]).order(created_at: :desc)
    if params[:t] == "1"
      @payments = @payments.where("amount < 0.0")
    elsif params[:t]  == "0"
      @payments = @payments.where("amount > 0.0")
    end
    
    respond_to do |format|
      format.html { @payments = @payments.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data @payments.to_csv }
    end
    
  end

  def show
    @payment = Payment.find_by(user_id: session[:user_id], id: params[:id])
  end
end
