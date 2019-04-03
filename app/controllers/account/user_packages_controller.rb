class Account::UserPackagesController < Account::BaseController
  
  def index
    @user_packages = UserPackage.includes(:package)
                                .where(user_id: session[:user_id], recurr_status: ["A", "D"])
                                .where("recurr_date > ?", Date.today)
  end
  
  def destroy
    @user_package = UserPackage.find_by(user_id: session[:user_id], id: params[:id])
    @user_package.update_column(:recurr_status, "D")
    
    flash[:success] = "Your subsciption has been marked for cancellation. It will remain active until #{@user_package.recurr_date} "
    redirect_to :back
  end
  
end
