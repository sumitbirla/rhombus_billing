# == Schema Information
#
# Table name: bill_package_details
#
#  id              :integer          not null, primary key
#  package_id      :integer          not null
#  service_type_id :integer          not null
#  quantity        :integer          not null
#  trial_days      :integer
#  rate            :decimal(10, 2)
#  hidden          :boolean          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class PackageDetail < ActiveRecord::Base
  self.table_name = 'bill_package_details'
  belongs_to :package
  belongs_to :service_type
  validates_presence_of :service_type_id, :quantity
end
