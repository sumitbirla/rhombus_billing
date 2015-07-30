class AddUsedToBillUserServices < ActiveRecord::Migration
  def change
    rename_column :bill_user_services, :available_quantity, :used
    rename_column :bill_user_services, :include_quantity, :quantity
  end
end
