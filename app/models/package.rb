# == Schema Information
#
# Table name: packages
#
#  id             :integer          not null, primary key
#  name           :string(255)      not null
#  description    :text             not null
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
  has_many :details, class_name: 'PackageDetail'
  validates_presence_of :name, :price, :bill_frequency

  def to_s
    name
  end
end
