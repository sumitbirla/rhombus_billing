# == Schema Information
#
# Table name: bill_service_types
#
#  id             :integer          not null, primary key
#  name           :string(255)      not null
#  code           :string(32)       default(""), not null
#  quantity_type  :string(255)      not null
#  bill_frequency :string(32)       default(""), not null
#  add_on         :boolean          not null
#  sort           :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#  domain_id      :integer          not null
#

class ServiceType < ActiveRecord::Base
  self.table_name = 'bill_service_types'
  
  belongs_to :domain
  validates_presence_of :name, :quantity_type, :sort
end
