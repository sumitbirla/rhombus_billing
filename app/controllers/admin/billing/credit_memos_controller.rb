class Admin::Billing::CreditMemosController < Admin::BaseController
  def index
    @credit_memos = CreditMemo.order(created_at: :desc)
                              .paginate(page: params[:page], per_page: @per_page)
  end

  def new
    @credit_memo = CreditMemo.new
    render 'edit'
  end

  def create
    @credit_memo = CreditMemo.new(credit_memo_params)
    
    if @credit_memo.save
      redirect_to action: 'index', notice: 'Credit Memo was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @credit_memo = CreditMemo.find(params[:id])
  end

  def edit
    @credit_memo = CreditMemo.find(params[:id])
  end

  def update
    @credit_memo = CreditMemo.find(params[:id])
    
    if @credit_memo.update(service_type_params)
      redirect_to action: 'index', notice: 'Credit Memo was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    CreditMemo.find(params[:id]).destroy
    redirect_to action: 'index', notice: 'Credit Memo has been deleted.'
  end
  
  def print
    @credit_memo = CreditMemo.find(params[:id])
    render 'print', layout: nil
  end
  
  
  private
  
    def credit_memo_params
      params.require(:credit_memo).permit!
    end
    
end
