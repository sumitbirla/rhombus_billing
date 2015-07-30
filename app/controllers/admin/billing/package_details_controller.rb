class Admin::Billing::PackageDetailsController < Admin::BaseController

  def new
    @package_detail = PackageDetail.new package_id: params[:package_id]
    render 'edit'
  end

  def create
    @package_detail = PackageDetail.new(package_detail_params)

    if @package_detail.save
      redirect_to details_admin_billing_package_path(@package_detail.package)
    else
      render 'edit'
    end
  end

  def edit
    @package_detail = PackageDetail.find(params[:id])
  end

  def update
    @package_detail = PackageDetail.find(params[:id])

    if @package_detail.update(package_detail_params)
      redirect_to details_admin_billing_package_path(@package_detail.package)
    else
      render 'edit'
    end
  end

  def destroy
    @package_detail = PackageDetail.find(params[:id])
    @package_detail.destroy
    redirect_to action: 'index', notice: 'Package detail has been deleted.'
  end

  def details
    @package = PackageDetail.find(params[:id])
  end


  private

    def package_detail_params
      params.require(:package_detail).permit!
    end

end