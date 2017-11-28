# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170329053442) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree
  end

  create_table "carpool_locations", force: :cascade do |t|
    t.integer "carpool_id"
    t.integer "location_id"
    t.index ["carpool_id", "location_id"], name: "by_carpool_and_location", unique: true, using: :btree
  end

  create_table "carpool_users", force: :cascade do |t|
    t.integer "user_id"
    t.integer "carpool_id"
    t.boolean "is_driver"
    t.boolean "is_passenger"
    t.boolean "is_active",    default: true
    t.index ["carpool_id", "user_id"], name: "by_carpool_and_user", unique: true, using: :btree
    t.index ["carpool_id"], name: "index_carpool_user_on_carpool_id", using: :btree
    t.index ["user_id"], name: "index_carpool_user_on_user_id", using: :btree
  end

  create_table "carpools", force: :cascade do |t|
    t.string   "title",                                      null: false
    t.string   "google_calendar_id"
    t.integer  "organization_id"
    t.string   "title_short",                                null: false
    t.string   "google_calendar_share_link"
    t.boolean  "publish_to_gcal",            default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_routes", force: :cascade do |t|
    t.integer "route_id"
    t.integer "event_id"
    t.index ["event_id"], name: "index_event_route_on_event_id", using: :btree
    t.index ["route_id", "event_id"], name: "by_event_and_route", unique: true, using: :btree
    t.index ["route_id"], name: "index_event_route_on_user_id", using: :btree
  end

  create_table "fullcalendar_engine_event_series", force: :cascade do |t|
    t.integer  "frequency",  default: 1
    t.string   "period",     default: "monthly"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",    default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fullcalendar_engine_events", force: :cascade do |t|
    t.string   "title"
    t.datetime "starttime"
    t.datetime "endtime"
    t.boolean  "all_day",         default: false
    t.text     "description"
    t.integer  "event_series_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_series_id"], name: "index_fullcalendar_engine_events_on_event_series_id", using: :btree
  end

  create_table "location_routes", force: :cascade do |t|
    t.integer "location_id"
    t.integer "route_id"
    t.boolean "arrived"
    t.integer "position"
    t.index ["location_id", "route_id", "position"], name: "by_location_and_user_and_position", unique: true, using: :btree
  end

  create_table "location_users", force: :cascade do |t|
    t.integer "location_id"
    t.integer "user_id"
    t.boolean "is_start_point"
    t.boolean "is_end_point"
    t.boolean "is_home"
    t.boolean "is_work"
    t.index ["location_id", "user_id"], name: "by_location_and_user", unique: true, using: :btree
    t.index ["location_id"], name: "index_location_users_on_location_id", using: :btree
    t.index ["user_id"], name: "index_location_users_on_user_id", using: :btree
  end

  create_table "locations", force: :cascade do |t|
    t.string   "title",            null: false
    t.text     "desc"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "intersectStreet1"
    t.string   "intersectStreet2"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "short_name",       null: false
  end

  create_table "organization_users", force: :cascade do |t|
    t.integer "organization_id"
    t.integer "user_id"
    t.string  "personal_gcal_id"
    t.index ["organization_id", "user_id"], name: "by_organization_and_user", unique: true, using: :btree
  end

  create_table "organizations", force: :cascade do |t|
    t.string   "title",       null: false
    t.string   "title_short", null: false
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id", using: :btree
    t.index ["name"], name: "index_roles_on_name", using: :btree
  end

  create_table "route_instances", force: :cascade do |t|
    t.integer "route_id"
    t.integer "instance_id"
    t.boolean "modified"
    t.index ["instance_id"], name: "index_route_instances_on_instance_id", using: :btree
    t.index ["route_id"], name: "index_route_instances_on_route_id", using: :btree
  end

  create_table "route_users", force: :cascade do |t|
    t.integer "route_id"
    t.integer "user_id"
    t.boolean "is_driver"
    t.boolean "is_passenger"
    t.integer "position"
    t.index ["route_id", "user_id"], name: "by_route_and_user", unique: true, using: :btree
    t.index ["route_id"], name: "index_route_user_on_route_id", using: :btree
    t.index ["user_id"], name: "index_route_user_on_user_id", using: :btree
  end

  create_table "routes", force: :cascade do |t|
    t.boolean  "completed",     default: false
    t.integer  "seq"
    t.integer  "passenger_cnt"
    t.text     "description"
    t.integer  "category",      default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.boolean  "modified",      default: false
    t.integer  "carpool_id",                    null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "authentication_token"
    t.string   "name"
    t.boolean  "can_drive",              default: false
    t.string   "first_name",                             null: false
    t.string   "last_name",                              null: false
    t.string   "home_phone"
    t.string   "mobile_phone"
    t.boolean  "mobile_phone_messaging"
    t.integer  "current_carpool_id"
    t.boolean  "subscribe_to_gcal",      default: false
    t.index ["authentication_token"], name: "index_users_on_authentication_token", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id", using: :btree
  end

end
