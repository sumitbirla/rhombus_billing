class Admin::Billing::PaymentsController < Admin::BaseController

  def index
    authorize Payment.new

    @payments = Payment.includes(:user, :affiliate).order(created_at: :desc)
    @payments = @payments.where(user_id: params[:uid]) unless params[:uid].nil?
    @payments = @payments.where("created_at > '#{params[:start_date]}'") unless params[:start_date].blank?
    @payments = @payments.where("created_at < '#{params[:end_date]}'") unless params[:end_date].blank?

    if params[:type] == "debit"
      @payments = @payments.where("amount < 0.0")
    elsif params[:type] == "credit"
      @payments = @payments.where("amount > 0.0")
    end

    respond_to do |format|
      format.html do
        @balance = @payments.sum(:amount)
        @payments = @payments.paginate(page: params[:page], per_page: @per_page)
      end
      format.csv { send_data Payment.to_csv(@payments) }
    end

  end

  def show
    @payment = authorize Payment.find(params[:id])
  end

  def new
    @payment = authorize Payment.new(user_id: params[:user_id], memo: 'New Payment')

    unless params[:order_id].nil?
      order = Order.find(params[:order_id])
      @payment.assign_attributes({
                                     payable_type: 'order',
                                     payable_id: order.id,
                                     memo: "Order ##{order.id}",
                                     amount: order.total,
                                     user_id: order.user_id,
                                     cc_cardholder_name: order.billing_name
                                 })
    end

    render 'edit'
  end

  def create
    @payment = authorize Payment.new(payment_params)

    if @payment.save
      flash[:notice] = 'Payment was successfully created.'
      if params[:redirect]
        redirect_to params[:redirect]
      else
        redirect_to action: 'index'
      end
    else
      render 'edit'
    end
  end

  def edit
    @payment = authorize Payment.find(params[:id])
  end

  def update
    @payment = authorize Payment.find(params[:id])

    if @payment.update(payment_params)
      flash[:notice] = 'Payment was successfully updated.'
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @payment = authorize Payment.find(params[:id])
    @payment.destroy

    flash[:notice] = 'Payment has been deleted.'
    redirect_to action: 'index'
  end


  def refund
    @payment = Payment.find(params[:id])
    authorize @payment, :update?
    response = @payment.refund(params[:amount].to_f, params[:memo])
    flash[:notice] = response.message
    redirect_back(fallback_location: admin_root_path)
  end


  private

  def payment_params
    params.require(:payment).permit!
  end

end
