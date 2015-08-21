class CreateCcTransactions < ActiveRecord::Migration
  def change
    create_table :bill_cc_transactions do |t|
      t.references :payment_method, index: true
      t.string :gateway, null: false
      t.string :action, null: false
      t.decimal :amount, null: false
      t.string :result, null: false
      t.text :data

      t.timestamps null: false
    end
  end
end
