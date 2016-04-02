class CreateBillingTables < ActiveRecord::Migration
  def change
    
    create_table "bill_cc_transactions", force: :cascade do |t|
      t.integer  "payment_method_id", limit: 4
      t.string   "gateway",           limit: 255,                           null: false
      t.string   "action",            limit: 255,                           null: false
      t.decimal  "amount",                          precision: 8, scale: 2, null: false
      t.string   "result",            limit: 255,                           null: false
      t.text     "data",              limit: 65535
      t.datetime "created_at",                                              null: false
      t.datetime "updated_at",                                              null: false
    end

    add_index "bill_cc_transactions", ["payment_method_id"], name: "index_bill_cc_transactions_on_payment_method_id", using: :btree

    create_table "bill_package_details", force: :cascade do |t|
      t.integer  "package_id",      limit: 4,                          null: false
      t.integer  "service_type_id", limit: 4,                          null: false
      t.integer  "quantity",        limit: 4,                          null: false
      t.integer  "trial_days",      limit: 4
      t.decimal  "rate",                      precision: 10, scale: 2
      t.boolean  "hidden",                                             null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_package_details", ["package_id"], name: "index_package_details_on_package_id", using: :btree
    add_index "bill_package_details", ["service_type_id"], name: "index_package_details_on_service_type_id", using: :btree

    create_table "bill_packages", force: :cascade do |t|
      t.integer  "domain_id",      limit: 4,                              null: false
      t.string   "name",           limit: 255,                            null: false
      t.string   "group",          limit: 255
      t.text     "description",    limit: 65535,                          null: false
      t.decimal  "price",                        precision: 10, scale: 2, null: false
      t.integer  "trial_days",     limit: 4
      t.integer  "bill_frequency", limit: 4,                              null: false
      t.boolean  "hidden",                                                null: false
      t.boolean  "active",                                                null: false
      t.integer  "sort",           limit: 4,                              null: false
      t.string   "image_path",     limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "bill_payment_methods", force: :cascade do |t|
      t.integer  "user_id",                 limit: 4,                     null: false
      t.string   "status",                  limit: 255,                   null: false
      t.boolean  "default",                               default: false, null: false
      t.string   "card_brand",              limit: 255,   default: "",    null: false
      t.string   "card_display",            limit: 255,   default: "",    null: false
      t.string   "cardholder_name",         limit: 255,                   null: false
      t.integer  "expiration_month",        limit: 4,                     null: false
      t.integer  "expiration_year",         limit: 4,                     null: false
      t.string   "billing_street1",         limit: 255,                   null: false
      t.string   "billing_street2",         limit: 255
      t.string   "billing_city",            limit: 255,                   null: false
      t.string   "billing_state",           limit: 255,                   null: false
      t.string   "billing_zip",             limit: 255,                   null: false
      t.string   "billing_country",         limit: 255,   default: "",    null: false
      t.text     "encrypted_cc",            limit: 65535,                 null: false
      t.text     "iv",                      limit: 65535,                 null: false
      t.string   "last_transaction_result", limit: 255
      t.datetime "last_transaction_date"
      t.integer  "bill_attempts",           limit: 4,     default: 0,     null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_payment_methods", ["user_id"], name: "index_payment_methods_on_user_id", using: :btree

    create_table "bill_payments", force: :cascade do |t|
      t.string   "payable_id",          limit: 255
      t.string   "payable_type",        limit: 255,                          default: ""
      t.integer  "user_id",             limit: 4,                                            null: false
      t.boolean  "customer",                                                 default: true,  null: false
      t.integer  "payment_method_id",   limit: 4
      t.decimal  "amount",                          precision: 10, scale: 2,                 null: false
      t.string   "transaction_id",      limit: 255
      t.string   "memo",                limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
      t.boolean  "cc",                                                       default: false, null: false
      t.string   "cc_type",             limit: 255
      t.string   "cc_cardholder_name",  limit: 255
      t.string   "cc_number",           limit: 255
      t.integer  "cc_expiration_month", limit: 4
      t.integer  "cc_expiration_year",  limit: 4
      t.string   "cc_code",             limit: 255
    end

    add_index "bill_payments", ["payment_method_id"], name: "index_payments_on_payment_method_id", using: :btree
    add_index "bill_payments", ["user_id"], name: "index_payments_on_user_id", using: :btree

    create_table "bill_service_types", force: :cascade do |t|
      t.integer  "domain_id",      limit: 4,                null: false
      t.string   "name",           limit: 255,              null: false
      t.string   "code",           limit: 32,  default: "", null: false
      t.string   "quantity_type",  limit: 255,              null: false
      t.string   "bill_frequency", limit: 255, default: "", null: false
      t.boolean  "add_on",                                  null: false
      t.integer  "sort",           limit: 4,                null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    create_table "bill_user_packages", force: :cascade do |t|
      t.integer  "user_id",                   limit: 4,                            null: false
      t.integer  "package_id",                limit: 4,                            null: false
      t.decimal  "amount",                                precision: 10, scale: 2, null: false
      t.decimal  "rate",                                  precision: 10, scale: 2, null: false
      t.date     "recurr_date",                                                    null: false
      t.string   "recurr_status",             limit: 255,                          null: false
      t.datetime "recurr_status_change_time"
      t.integer  "bill_attempts",             limit: 4,                            null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_user_packages", ["package_id"], name: "index_user_packages_on_package_id", using: :btree
    add_index "bill_user_packages", ["user_id"], name: "index_user_packages_on_user_id", using: :btree

    create_table "bill_user_service_items", force: :cascade do |t|
      t.integer  "user_service_id", limit: 4,   null: false
      t.integer  "item_id",         limit: 4,   null: false
      t.string   "item_type",       limit: 255, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_user_service_items", ["user_service_id"], name: "index_user_service_items_on_user_service_id", using: :btree

    create_table "bill_user_services", force: :cascade do |t|
      t.integer  "user_package_id", limit: 4,                          null: false
      t.integer  "service_type_id", limit: 4,                          null: false
      t.integer  "quantity",        limit: 4,                          null: false
      t.integer  "used",            limit: 4,                          null: false
      t.decimal  "rate",                      precision: 10, scale: 2, null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "bill_user_services", ["service_type_id"], name: "index_user_services_on_service_type_id", using: :btree
    add_index "bill_user_services", ["user_package_id"], name: "index_user_services_on_user_package_id", using: :btree

    create_table "bill_user_voucher_histories", force: :cascade do |t|
      t.integer  "user_id",    limit: 4,                            null: false
      t.integer  "voucher_id", limit: 4
      t.decimal  "amount",                 precision: 10, scale: 2, null: false
      t.integer  "order_id",   limit: 4
      t.string   "notes",      limit: 255
      t.datetime "created_at"
      t.datetime "updated_at"
    end
    
  end
end
