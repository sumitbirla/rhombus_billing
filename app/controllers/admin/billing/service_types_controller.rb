class Admin::Billing::ServiceTypesController < Admin::BaseController

  def index
    authorize ServiceType.new
    @service_types = ServiceType.where(domain_id: cookies[:domain_id]).order(:sort)

    respond_to do |format|
      format.html { @service_types = @service_types.paginate(page: params[:page], per_page: @per_page) }
      format.csv { send_data ServiceType.to_csv(@service_types) }
    end
  end

  def new
    @service_type = authorize ServiceType.new(name: 'New service type')
    render 'edit'
  end

  def create
    @service_type = authorize ServiceType.new(service_type_params)
    @service_type.domain_id = cookies[:domain_id]

    if @service_type.save
      redirect_to action: 'index', notice: 'Service Type was successfully created.'
    else
      render 'edit'
    end
  end

  def show
    @service_type = authorize ServiceType.find(params[:id])
  end

  def edit
    @service_type = authorize ServiceType.find(params[:id])
  end

  def update
    @service_type = authorize ServiceType.find(params[:id])

    if @service_type.update(service_type_params)
      redirect_to action: 'index', notice: 'Service Type was successfully updated.'
    else
      render 'edit'
    end
  end

  def destroy
    @service_type = authorize ServiceType.find(params[:id])
    @service_type.destroy
    redirect_to action: 'index', notice: 'Service Type has been deleted.'
  end


  private

  def service_type_params
    params.require(:service_type).permit!
  end

end
