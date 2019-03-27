class Account::UserPackagesController < Account::BaseController
  
  def index
    @user_packages = UserPackage.includes(:package).where(user_id: session[:user_id], recurr_status: "A")
  end
  
  
end
