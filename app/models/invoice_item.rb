class InvoiceItem < ActiveRecord::Base
  include Exportable
  self.table_name = 'bill_invoice_items'
  
  belongs_to :invoice
  validates_presence_of :unit_price, :quantity, :item_number, :item_description

end