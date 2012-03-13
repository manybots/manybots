class CreateActivityObjects < ActiveRecord::Migration
  def self.up
    create_table :activity_objects do |t|
      t.integer   :activity_id
      t.string    :type
      t.string    :url_id
      t.text      :title
      t.datetime  :posted_time
      t.string    :object_type
      t.text      :payload
      t.string    :remote_id

      t.timestamps
    end
    
    add_index :activity_objects, :activity_id
    add_index :activity_objects, :type
    add_index :activity_objects, :object_type
    add_index :activity_objects, :title
    add_index :activity_objects, [:type, :activity_id], :name => 'activity_objects_type_and_activity_id'
    
  end

  def self.down
    remove_index :activity_objects
    drop_table :activity_objects
  end
end
