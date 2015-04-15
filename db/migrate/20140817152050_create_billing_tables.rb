class CreateBillingTables < ActiveRecord::Migration
  def change
    
    create_table "bill_package_details", force: true do |t|
      t.integer  "package_id",                               null: false
      t.integer  "service_type_id",                          null: false
      t.integer  "quantity",                                 null: false
      t.integer  "trial_days"
      t.decimal  "rate",            precision: 10, scale: 2
      t.boolean  "hidden",                                   null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_package_details", ["package_id"], name: "index_package_details_on_package_id", using: :btree
    add_index "bill_package_details", ["service_type_id"], name: "index_package_details_on_service_type_id", using: :btree

    create_table "bill_packages", force: true do |t|
      t.string   "name",                                    null: false
      t.string   "group"
      t.text     "description",                             null: false
      t.decimal  "price",          precision: 10, scale: 2, null: false
      t.integer  "trial_days"
      t.integer  "bill_frequency",                          null: false
      t.boolean  "hidden",                                  null: false
      t.boolean  "active",                                  null: false
      t.integer  "sort",                                    null: false
      t.string   "image_path"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "bill_payment_methods", force: true do |t|
      t.integer  "user_id",                                 null: false
      t.boolean  "default",                 default: false, null: false
      t.string   "card_brand",              default: "",    null: false
      t.string   "card_display",            default: "",    null: false
      t.string   "cardholder_name",                         null: false
      t.integer  "expiration_month",                        null: false
      t.integer  "expiration_year",                         null: false
      t.string   "billing_street1",                         null: false
      t.string   "billing_street2"
      t.string   "billing_city",                            null: false
      t.string   "billing_state",                           null: false
      t.string   "billing_zip",                             null: false
      t.string   "billing_country",         default: "",    null: false
      t.text     "encrypted_cc",                            null: false
      t.text     "iv",                                      null: false
      t.string   "status",                                  null: false
      t.string   "last_transaction_result"
      t.datetime "last_transaction_date"
      t.integer  "bill_attempts",           default: 0,     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_payment_methods", ["user_id"], name: "index_payment_methods_on_user_id", using: :btree

    create_table "bill_payments", force: true do |t|
      t.integer  "payable_id"
      t.string   "payable_type",                               default: ""
      t.integer  "user_id"
      t.integer  "payment_method_id"
      t.decimal  "amount",            precision: 10, scale: 2,              null: false
      t.string   "transaction_id"
      t.string   "memo"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_payments", ["payment_method_id"], name: "index_payments_on_payment_method_id", using: :btree
    add_index "bill_payments", ["user_id"], name: "index_payments_on_user_id", using: :btree
    
    create_table "bill_service_types", force: true do |t|
      t.string   "name",          null: false
      t.string   "code",          null: false
      t.string   "quantity_type", null: false
      t.string   "bill_frequency",null: false
      t.boolean  "add_on",        null: false
      t.integer  "sort",          null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
    create_table "bill_user_packages", force: true do |t|
      t.integer  "user_id",                                            null: false
      t.integer  "package_id",                                         null: false
      t.decimal  "amount",                    precision: 10, scale: 2, null: false
      t.decimal  "rate",                      precision: 10, scale: 2, null: false
      t.date     "recurr_date",                                        null: false
      t.string   "recurr_status",                                      null: false
      t.datetime "recurr_status_change_time"
      t.integer  "bill_attempts",                                      null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_user_packages", ["package_id"], name: "index_user_packages_on_package_id", using: :btree
    add_index "bill_user_packages", ["user_id"], name: "index_user_packages_on_user_id", using: :btree

    create_table "bill_user_service_items", force: true do |t|
      t.integer  "user_service_id", null: false
      t.integer  "item_id",         null: false
      t.string   "item_type",       null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_user_service_items", ["user_service_id"], name: "index_user_service_items_on_user_service_id", using: :btree

    create_table "bill_user_services", force: true do |t|
      t.integer  "user_package_id",                             null: false
      t.integer  "service_type_id",                             null: false
      t.integer  "include_quantity",                            null: false
      t.integer  "available_quantity",                          null: false
      t.decimal  "rate",               precision: 10, scale: 2, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_user_services", ["service_type_id"], name: "index_user_services_on_service_type_id", using: :btree
    add_index "bill_user_services", ["user_package_id"], name: "index_user_services_on_user_package_id", using: :btree

    create_table "bill_user_voucher_histories", force: true do |t|
      t.integer  "user_id",                             null: false
      t.integer  "voucher_id"
      t.decimal  "amount",     precision: 10, scale: 2, null: false
      t.integer  "order_id"
      t.string   "notes"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
  end
end
