class Admin::Billing::CcTransactionsController < Admin::BaseController

  def index
    
    @cc_transactions = CcTransaction.includes(:payment_method).order(created_at: :desc)
    @cc_transactions = @cc_transactions.where("created_at > '#{params[:start_date]}'") unless params[:start_date].blank?
    @cc_transactions = @cc_transactions.where("created_at < '#{params[:end_date]}'") unless params[:end_date].blank?
    
    respond_to do |format|
      format.html do
        @cc_transactions = @cc_transactions.page(params[:page])
      end
      format.csv { send_data @cc_transactions.to_csv }
    end
    
  end
  
  def show
    @cc_transaction = CcTransaction.find(params[:id])
  end
  
end
