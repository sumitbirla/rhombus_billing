class AddDomainIdToBillPackages < ActiveRecord::Migration
  def change
    add_column :bill_packages, :domain_id, :integer, after: :id, null: false
  end
end
