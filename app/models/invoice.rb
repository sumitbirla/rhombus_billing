# == Schema Information
#
# Table name: bill_invoices
#
#  id               :integer          not null, primary key
#  invoiceable_id   :integer          not null
#  invoiceable_type :string(255)      not null
#  amount           :decimal(10, 2)   not null
#  due_date         :date
#  paid             :boolean          default(FALSE), not null
#  note             :text(65535)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Invoice < ActiveRecord::Base
  self.table_name = 'bill_invoices'

  belongs_to :user
  belongs_to :affiliate
  belongs_to :from_affiliate, class_name: 'Affiliate'

  has_many :logs, as: :loggable
  has_many :payments, as: :payable

  accepts_nested_attributes_for :payments, reject_if: lambda { |x| x['amount'].blank? }, allow_destroy: true

  validates_presence_of :amount, :from_affiliate_id
  validate :issued_to

  def issued_to
    if (user_id.nil? && affiliate_id.nil?)
      errors.add(:base, "Specified issued_to user or affiliate")
    end
  end

  # PUNDIT
  def self.policy_class
    ApplicationPolicy
  end
end
