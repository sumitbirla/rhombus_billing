class Account::UserPackagesController < Account::BaseController
  
  def index
    @user_packages = UserPackage.includes(:package).where(user_id: session[:user_id], recurr_status: "A")
  end
  
  def destroy
    @user_package = UserPackage.find_by(user_id: session[:user_id], id: params[:id])
    @user_package.update_column(:recurr_status, "C")
    
    flash.now[:success] = "Your subsciption has been cancelled"
    redirect_to :back
  end
  
end
