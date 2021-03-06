# == Schema Information
#
# Table name: bill_user_packages
#
#  id                        :integer          not null, primary key
#  amount                    :decimal(10, 2)   not null
#  bill_attempts             :integer          not null
#  rate                      :decimal(10, 2)   not null
#  recurr_date               :date             not null
#  recurr_status             :string(255)      not null
#  recurr_status_change_time :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  package_id                :integer          not null
#  user_id                   :integer          not null
#
# Indexes
#
#  index_user_packages_on_package_id  (package_id)
#  index_user_packages_on_user_id     (user_id)
#

class UserPackage < ActiveRecord::Base
  include Exportable
  self.table_name = 'bill_user_packages'

  belongs_to :user
  belongs_to :package
  has_many :services, class_name: 'UserService', dependent: :destroy
  has_many :payments, as: :payable
  has_many :invoices, as: :invoiceable

  accepts_nested_attributes_for :services

  def get_service(code)
    code = ServiceType.find_by(code: code).id if code.is_a?(String)
    services.find { |x| x.service_type_id == code }
  end

  def total_price
    total = rate

    services.each do |s|
      if s.used > s.quantity
        total += (s.used - s.quantity) * s.rate
      end
    end

    total
  end

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end

end
