# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120421100722) do

  create_table "activities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_application_id"
    t.string   "url_id"
    t.string   "verb"
    t.string   "stream_favicon_url"
    t.string   "generator_url"
    t.string   "generator_title"
    t.text     "title"
    t.text     "summary"
    t.text     "content"
    t.string   "lang"
    t.datetime "posted_time"
    t.string   "permalink"
    t.boolean  "is_public"
    t.string   "service_provider_name"
    t.string   "service_provider_icon"
    t.string   "service_provider_uri"
    t.text     "payload"
    t.text     "clean_title"
    t.text     "clean_summary"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  add_index "activities", ["client_application_id"], :name => "index_activities_on_client_application_id"
  add_index "activities", ["posted_time", "user_id"], :name => "posted_time_and_user_id"
  add_index "activities", ["posted_time"], :name => "index_activities_on_posted_time"
  add_index "activities", ["url_id"], :name => "index_activities_on_url_id"
  add_index "activities", ["user_id"], :name => "index_activities_on_user_id"

  create_table "activities_aggregations", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "aggregation_id"
  end

  add_index "activities_aggregations", ["activity_id", "aggregation_id"], :name => "index_activities_aggregations_on_activity_id_and_aggregation_id"
  add_index "activities_aggregations", ["activity_id"], :name => "index_activities_aggregations_on_activity_id"
  add_index "activities_aggregations", ["aggregation_id"], :name => "index_activities_aggregations_on_aggregation_id"

  create_table "activity_objects", :force => true do |t|
    t.integer  "activity_id"
    t.string   "type"
    t.string   "url_id"
    t.text     "title"
    t.datetime "posted_time"
    t.string   "object_type"
    t.text     "payload"
    t.string   "remote_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "activity_objects", ["activity_id"], :name => "index_activity_objects_on_activity_id"
  add_index "activity_objects", ["object_type"], :name => "index_activity_objects_on_object_type"
  add_index "activity_objects", ["title"], :name => "index_activity_objects_on_title"
  add_index "activity_objects", ["type", "activity_id"], :name => "activity_objects_type_and_activity_id"
  add_index "activity_objects", ["type"], :name => "index_activity_objects_on_type"

  create_table "aggregations", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "type_string"
    t.integer  "total"
    t.string   "object_type"
    t.string   "avatar_url"
    t.string   "path"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "aggregations_notifications", :id => false, :force => true do |t|
    t.integer "aggregation_id"
    t.integer "notification_id"
  end

  create_table "aggregations_predictions", :id => false, :force => true do |t|
    t.integer "aggregation_id"
    t.integer "prediction_id"
  end

  create_table "bundles", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.string   "slug"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",            :limit => 40
    t.string   "secret",         :limit => 40
    t.integer  "user_id"
    t.text     "description"
    t.string   "avatar_url"
    t.boolean  "is_public",                    :default => false
    t.string   "app_icon_url"
    t.string   "developer_name"
    t.string   "developer_url"
    t.string   "nickname"
    t.string   "category"
    t.string   "app_type"
    t.boolean  "offers_login",                 :default => false
    t.boolean  "offers_exports",               :default => false
    t.boolean  "offers_reading",               :default => false
    t.string   "screenshot"
    t.boolean  "is_trusted",                   :default => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "target_objects"
    t.boolean  "in_library"
    t.boolean  "in_menu"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true
  add_index "client_applications", ["nickname"], :name => "index_client_applications_on_nickname", :unique => true

  create_table "filters", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "slug"
    t.string   "tag_list"
    t.text     "description"
    t.text     "payload"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "installed_applications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_application_id"
    t.boolean  "in_menu",               :default => false
    t.boolean  "in_library",            :default => false
    t.boolean  "is_default",            :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "installed_applications", ["client_application_id"], :name => "index_installed_applications_on_client_application_id"
  add_index "installed_applications", ["user_id"], :name => "index_installed_applications_on_user_id"

  create_table "manybots_github_commits", :force => true do |t|
    t.integer  "repository_id"
    t.text     "message"
    t.string   "sha"
    t.text     "payload"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "manybots_github_commits", ["repository_id"], :name => "index_manybots_github_commits_on_repository_id"

  create_table "manybots_github_repositories", :force => true do |t|
    t.integer  "oauth_account_id"
    t.string   "slug"
    t.integer  "remote_id"
    t.text     "payload"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "manybots_gmail_emails", :force => true do |t|
    t.integer  "user_id"
    t.string   "address"
    t.integer  "muid"
    t.text     "people"
    t.text     "subject"
    t.string   "tags"
    t.datetime "sent_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "manybots_gmail_pizzahut_meals", :force => true do |t|
    t.integer  "user_id"
    t.integer  "email_order_id"
    t.datetime "ordered_at"
    t.text     "payload"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "manybots_googlecalendar_events", :force => true do |t|
    t.integer  "oauth_account_id"
    t.string   "remote_id"
    t.datetime "remote_created_at"
    t.datetime "remote_updated_at"
    t.text     "payload"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "manybots_googlecalendar_events", ["oauth_account_id"], :name => "index_manybots_googlecalendar_events_on_oauth_account_id"

  create_table "manybots_weather_locations", :force => true do |t|
    t.integer  "user_id"
    t.string   "code"
    t.string   "name"
    t.string   "lat"
    t.string   "long"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "manybots_weather_locations", ["user_id"], :name => "index_manybots_weather_locations_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_application_id"
    t.integer  "activity_id"
    t.string   "notification_type"
    t.string   "notification_level"
    t.string   "uid"
    t.string   "url"
    t.datetime "published"
    t.datetime "updated"
    t.string   "icon_url"
    t.text     "title"
    t.text     "summary"
    t.text     "content"
    t.string   "verb"
    t.string   "actor_name"
    t.string   "actor_type"
    t.string   "actor_url"
    t.string   "actor_uid"
    t.string   "actor_avatar_url"
    t.string   "object_type"
    t.string   "object_name"
    t.string   "object_url"
    t.string   "object_uid"
    t.string   "target_type"
    t.string   "target_name"
    t.string   "target_url"
    t.string   "target_uid"
    t.string   "provider_name"
    t.string   "provider_icon"
    t.string   "provider_url"
    t.string   "generator_name"
    t.string   "generator_icon"
    t.string   "generator_url"
    t.text     "payload"
    t.boolean  "is_read",               :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "oauth_accounts", :force => true do |t|
    t.integer  "client_application_id"
    t.integer  "user_id"
    t.string   "token"
    t.string   "secret"
    t.string   "remote_account_id"
    t.text     "payload"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 40
    t.string   "secret",                :limit => 40
    t.string   "callback_url"
    t.string   "verifier",              :limit => 20
    t.string   "scope"
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "valid_to"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "predictions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "client_application_id"
    t.integer  "predictable_id"
    t.string   "predictable_type"
    t.integer  "activity_id"
    t.string   "prediction_type"
    t.string   "prediction_level"
    t.string   "uid"
    t.string   "url"
    t.datetime "published"
    t.datetime "updated"
    t.string   "icon_url"
    t.text     "title"
    t.text     "summary"
    t.text     "content"
    t.string   "verb"
    t.string   "actor_name"
    t.string   "actor_type"
    t.string   "actor_url"
    t.string   "actor_uid"
    t.string   "actor_avatar_url"
    t.string   "object_type"
    t.string   "object_name"
    t.string   "object_url"
    t.string   "object_uid"
    t.string   "target_type"
    t.string   "target_name"
    t.string   "target_url"
    t.string   "target_uid"
    t.string   "provider_name"
    t.string   "provider_icon"
    t.string   "provider_url"
    t.string   "generator_name"
    t.string   "generator_icon"
    t.string   "generator_url"
    t.text     "payload"
    t.boolean  "came_true",             :default => false
    t.boolean  "canceled",              :default => false
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
  end

  add_index "predictions", ["user_id"], :name => "index_predictions_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",   :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",   :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "name"
    t.string   "avatar_source"
    t.string   "avatar_url"
    t.string   "country"
    t.boolean  "is_first_login",                      :default => true
    t.string   "authentication_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
