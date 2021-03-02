# == Schema Information
#
# Table name: bill_user_services
#
#  id              :integer          not null, primary key
#  quantity        :integer          not null
#  rate            :decimal(10, 2)   not null
#  used            :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  service_type_id :integer          not null
#  user_package_id :integer          not null
#
# Indexes
#
#  index_user_services_on_service_type_id  (service_type_id)
#  index_user_services_on_user_package_id  (user_package_id)
#

class UserService < ActiveRecord::Base
  self.table_name = 'bill_user_services'
  belongs_to :user_package
  belongs_to :service_type
  has_many :items, class_name: 'UserServiceItem', dependent: :destroy

  def overage
    (used > quantity) ? used - quantity : 0
  end

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
