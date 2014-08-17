class Admin::Billing::UserPackagesController < Admin::BaseController

  def index
    @user_packages = UserPackage.where(recurr_status: 'A').includes(:package, :user).page(params[:page]).order(:recurr_date)
  end

  def new
    @user_package = UserPackage.new
    render 'edit'
  end

  def create
    @user_package = UserPackage.new(user_package_params)

    if @user_package.save

      # include user services
      @user_package.package.details.each do |detail|

      end

      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def show
    @user_package = UserPackage.includes(:services, [services: :service_type], [services: :items]).find(params[:id])
  end

  def edit
    @user_package = UserPackage.find(params[:id])
  end

  def update
    @user_package = UserPackage.find(params[:id])

    if @user_package.update(user_package_params)
      redirect_to action: 'index'
    else
      render 'edit'
    end
  end

  def destroy
    @user_package = UserPackage.find(params[:id])
    @user_package.destroy
    redirect_to action: 'index'
  end


  def services
    @user_package = UserPackage.includes(:services, [services: :service_type], [services: :items]).find(params[:id])
  end


  private

    def user_package_params
      params.require(:user_package).permit(:user_id, :package_id, :amount, :rate, :recurr_date, :recurr_status, :bill_attempts)
    end

end
