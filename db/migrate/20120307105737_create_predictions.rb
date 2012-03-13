class CreatePredictions < ActiveRecord::Migration
  def change
    create_table :predictions do |t|
      t.column 'user_id', :integer
      t.column 'client_application_id', :integer
      t.column 'predictable_id', :integer
      t.column 'predictable_type', :string
      t.column 'activity_id', :integer
      t.column 'prediction_type', :string
      t.column 'prediction_level', :string
      t.column 'uid', :string
      t.column 'url', :string
      t.column 'published', :datetime
      t.column 'updated', :datetime
      t.column 'icon_url', :string
      t.column 'title', :text
      t.column 'summary', :text
      t.column 'content', :text
      t.column 'verb', :string
      t.column 'actor_name', :string
      t.column 'actor_type', :string
      t.column 'actor_url', :string
      t.column 'actor_uid', :string
      t.column 'actor_avatar_url', :string
      t.column 'object_type', :string
      t.column 'object_name', :string
      t.column 'object_url', :string
      t.column 'object_uid', :string
      t.column 'target_type', :string
      t.column 'target_name', :string
      t.column 'target_url', :string
      t.column 'target_uid', :string
      t.column 'provider_name', :string
      t.column 'provider_icon', :string
      t.column 'provider_url', :string
      t.column 'generator_name', :string
      t.column 'generator_icon', :string
      t.column 'generator_url', :string
      t.column 'payload', :text
      t.column 'came_true', :boolean, :default => false
      t.column 'canceled', :boolean, :default => false
      
      t.timestamps
    end
    
    add_index :predictions, :user_id
  end
end
