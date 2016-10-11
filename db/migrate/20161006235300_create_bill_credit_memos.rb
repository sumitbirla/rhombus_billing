class CreateBillCreditMemos < ActiveRecord::Migration
  def change
    create_table :bill_credit_memos do |t|
      t.integer :user_id
      t.integer :affiliate_id
      t.decimal :amount, scale: 2, precision: 10, null: false
      t.string :description, null: false
      t.decimal :used, scale: 2, precision: 10, null: false
      t.timestamps
    end
  end
end
