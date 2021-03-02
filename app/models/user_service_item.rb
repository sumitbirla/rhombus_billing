# == Schema Information
#
# Table name: bill_user_service_items
#
#  id              :integer          not null, primary key
#  item_type       :string(255)      not null
#  created_at      :datetime
#  updated_at      :datetime
#  item_id         :integer          not null
#  user_service_id :integer          not null
#
# Indexes
#
#  index_user_service_items_on_user_service_id  (user_service_id)
#

class UserServiceItem < ActiveRecord::Base
  self.table_name = 'bill_user_service_items'
  belongs_to :user_service
end
