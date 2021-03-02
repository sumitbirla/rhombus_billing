# == Schema Information
#
# Table name: bill_package_details
#
#  id              :integer          not null, primary key
#  hidden          :boolean          not null
#  quantity        :integer          not null
#  rate            :decimal(10, 2)
#  trial_days      :integer
#  created_at      :datetime
#  updated_at      :datetime
#  package_id      :integer          not null
#  service_type_id :integer          not null
#
# Indexes
#
#  index_package_details_on_package_id       (package_id)
#  index_package_details_on_service_type_id  (service_type_id)
#

class PackageDetail < ActiveRecord::Base
  self.table_name = 'bill_package_details'
  belongs_to :package
  belongs_to :service_type
  validates_presence_of :service_type_id, :quantity
end
