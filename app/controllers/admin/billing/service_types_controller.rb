class Admin::Billing::ServiceTypesController < Admin::BaseController
  
  def index
    @service_types = ServiceType.where(domain_id: cookies[:domain_id]).page(params[:page]).order(:sort)
  end

  def new
    @service_type = ServiceType.new name: 'New service type'
    render 'edit'
  end

  def create
    @service_type = ServiceType.new(service_type_params)
    @service_type.domain_id = cookies[:domain_id]
    
    if @service_type.save
      redirect_to action: 'index', notice: 'Service Type was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @service_type = ServiceType.find(params[:id])
  end

  def edit
    @service_type = ServiceType.find(params[:id])
  end

  def update
    @service_type = ServiceType.find(params[:id])
    
    if @service_type.update(service_type_params)
      redirect_to action: 'index', notice: 'Service Type was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @service_type = ServiceType.find(params[:id])
    @service_type.destroy
    redirect_to action: 'index', notice: 'Service Type has been deleted.'
  end
  
  
  private
  
    def service_type_params
      params.require(:service_type).permit!
    end
  
end
