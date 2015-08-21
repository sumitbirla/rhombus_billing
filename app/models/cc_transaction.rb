class CcTransaction < ActiveRecord::Base
  self.table_name = "bill_cc_transactions"
  belongs_to :payment_method
  validates_presence_of :payment_method_id, :gateway, :action, :amount, :result
  
  def self.to_csv
    CSV.generate do |csv|
      cols = column_names
      csv << cols
      all.each do |pmt|
        csv << pmt.attributes.values_at(*cols)
      end
    end
  end
  
end
