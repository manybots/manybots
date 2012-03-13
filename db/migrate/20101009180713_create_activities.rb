class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.integer :user_id
      t.integer :client_application_id
      t.string :url_id
      t.string :verb
      t.string :stream_favicon_url
      t.string :generator_url
      t.string :generator_title
      t.text :title
      t.text :summary
      t.text :content
      t.string :lang
      t.datetime :posted_time
      t.string :permalink
      t.boolean :is_public
      t.string :service_provider_name
      t.string :service_provider_icon
      t.string :service_provider_uri
      t.text  :payload
      t.text  :clean_title
      t.text  :clean_summary

      t.timestamps
    end

    add_index :activities, :url_id
    add_index :activities, :user_id
    add_index :activities, :client_application_id
    add_index :activities, [:posted_time, :user_id], :name => 'posted_time_and_user_id'
    add_index :activities, :posted_time, :name => 'index_activities_on_posted_time'
  end

  def self.down
    remove_index :activities
    
    drop_table :activities
  end
end
