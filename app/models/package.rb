# == Schema Information
#
# Table name: bill_packages
#
#  id             :integer          not null, primary key
#  domain_id      :integer          not null
#  name           :string(255)      not null
#  group          :string(255)
#  description    :text(65535)      not null
#  price          :decimal(10, 2)   not null
#  trial_days     :integer
#  bill_frequency :integer          not null
#  hidden         :boolean          not null
#  active         :boolean          not null
#  sort           :integer          not null
#  image_path     :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Package < ActiveRecord::Base
  self.table_name = 'bill_packages'
  
  belongs_to :domain
  has_many :details, class_name: 'PackageDetail', dependent: :destroy
  validates_presence_of :name, :price, :bill_frequency

  def to_s
    name
  end
  
  def get_detail(service_code)
    details.find { |x| x.service_type.code == service_code }
  end
end
