# == Schema Information
#
# Table name: bill_user_services
#
#  id                 :integer          not null, primary key
#  user_package_id    :integer          not null
#  service_type_id    :integer          not null
#  include_quantity   :integer          not null
#  available_quantity :integer          not null
#  rate               :decimal(10, 2)   not null
#  created_at         :datetime
#  updated_at         :datetime
#

class UserService < ActiveRecord::Base
  self.table_name = 'bill_user_services'
  belongs_to :user_package
  belongs_to :service_type
  has_many :items, class_name: 'UserServiceItem', dependent: :destroy
end
