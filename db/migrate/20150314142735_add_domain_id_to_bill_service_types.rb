class AddDomainIdToBillServiceTypes < ActiveRecord::Migration
  def change
    add_column :bill_service_types, :domain_id, :integer, null: false
  end
end
