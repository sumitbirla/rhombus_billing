class Admin::Billing::UserServicesController < Admin::BaseController

  def new
    @user_service = UserService.new user_package_id: params[:user_package_id]
    render 'edit'
  end

  def create
    @user_service = UserService.new(user_service_params)

    if @user_service.save
      redirect_to services_admin_billing_user_package_path(@user_service.user_package_id)
    else
      render 'edit'
    end
  end

  def edit
    @user_service = UserService.find(params[:id])
  end

  def update
    @user_service = UserService.find(params[:id])

    if @user_service.update(user_service_params)
      redirect_to services_admin_billing_user_package_path(@user_service.user_package_id)
    else
      render 'edit'
    end
  end

  def destroy
    @user_service = UserService.find(params[:id])
    @user_service.destroy
    redirect_to :back
  end


  private

    def user_service_params
      params.require(:user_service).permit!
    end

end