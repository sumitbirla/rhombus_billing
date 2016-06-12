class Admin::Billing::CcTransactionsController < Admin::BaseController

  def index
    @cc_transactions = CcTransaction.joins(:payment_method)
                                    .includes(:payment_method)
                                    .order(sort_column + " " + sort_direction)
                                    
    @cc_transactions = @cc_transactions.where("created_at > '#{params[:start_date]}'") unless params[:start_date].blank?
    @cc_transactions = @cc_transactions.where("created_at < '#{params[:end_date]}'") unless params[:end_date].blank?
    
    respond_to do |format|
      format.html { @cc_transactions = @cc_transactions.page(params[:page]) }
      format.csv { send_data CcTransaction.to_csv(@cc_transactions) }
    end
    
  end
  
  def show
    @cc_transaction = CcTransaction.find(params[:id])
  end
  
  
  private
  
    def sort_column
       params[:sort] || "bill_cc_transactions.created_at"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
  
end
