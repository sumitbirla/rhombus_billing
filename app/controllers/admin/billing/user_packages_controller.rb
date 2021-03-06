class Admin::Billing::UserPackagesController < Admin::BaseController

  def index
    authorize UserPackage.new
    @user_packages = UserPackage.joins(:package)
                         .where("bill_packages.domain_id = #{cookies[:domain_id]}")
                         .where(recurr_status: 'A')
                         .includes(:package, :user)
                         .order(:recurr_date)

    respond_to do |format|
      format.html { @user_packages = @user_packages.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data UserPackage.to_csv(@user_packages) }
    end
  end

  def new
    @user_package = authorize UserPackage.new
    render 'edit'
  end

  def create
    @user_package = authorize UserPackage.new(user_package_params)

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
    @user_package = authorize UserPackage.includes(:services, [services: :service_type], [services: :items]).find(params[:id])
  end

  def edit
    @user_package = authorize UserPackage.find(params[:id])
  end

  def update
    @user_package = authorize UserPackage.find(params[:id])

    if @user_package.update(user_package_params)
      redirect_to action: 'show', id: params[:id]
    else
      render 'edit'
    end
  end

  def destroy
    @user_package = authorize UserPackage.find(params[:id])
    @user_package.destroy
    redirect_to action: 'index'
  end

  def add_service
    authorize UserPackage, :update?
    UserService.create(user_package_id: params[:id], service_type_id: params[:service_type_id], quantity: 0, used: 0, rate: 0)
    redirect_back(fallback_location: admin_root_path)
  end


  def services
    @user_package = UserPackage.includes(:services, [services: :service_type], [services: :items]).find(params[:id])
    authorize @user_package, :show?
  end


  private

  def user_package_params
    params.require(:user_package).permit!
  end

end
