# == Schema Information
#
# Table name: bill_user_service_items
#
#  id              :integer          not null, primary key
#  user_service_id :integer          not null
#  item_id         :integer          not null
#  item_type       :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#

class UserServiceItem < ActiveRecord::Base
  self.table_name = 'bill_user_service_items'
  belongs_to :user_service
end
