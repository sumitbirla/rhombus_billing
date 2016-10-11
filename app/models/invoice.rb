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
  belongs_to :invoiceable, polymorphic: true
  
  has_many :items, class_name: 'InvoiceItem'
  has_and_belongs_to_many :payments
  
  accepts_nested_attributes_for :items, reject_if: lambda { |x| x['quantity'].blank? }, allow_destroy: true
  
end
