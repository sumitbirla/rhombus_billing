class Admin::Billing::PackagesController < Admin::BaseController
  
  def index
    authorize Package.new
    @packages = Package.where(domain_id: cookies[:domain_id])
    
    respond_to do |format|
      format.html { @packages = @packages.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data Package.to_csv(@packages) }
    end
  end

  def new
    @package = authorize Package.new(name: 'New Package', sort: 9, trial_days: 0)
    render 'edit'
  end

  def create
    @package = authorize Package.new(package_params)
    @package.domain_id = cookies[:domain_id]
    
    if @package.save
      redirect_to action: 'index', notice: 'Package was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @package = authorize Package.includes(:details, [details: :service_type]).find(params[:id])
  end

  def edit
    @package = authorize Package.find(params[:id])
  end

  def update
    @package = authorize Package.find(params[:id])
    
    if @package.update(package_params)
      redirect_to action: 'index', notice: 'Package was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @package = authorize Package.find(params[:id])
    @package.destroy
    redirect_to action: 'index', notice: 'Package has been deleted.'
  end


  def details
    @package = Package.find(params[:id])
    authorize @package, :show?
  end

  
  private
  
    def package_params
      params.require(:package).permit!
    end
  
end
