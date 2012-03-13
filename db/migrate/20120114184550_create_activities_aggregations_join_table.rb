class CreateActivitiesAggregationsJoinTable < ActiveRecord::Migration
  def self.up
    create_table :activities_aggregations, :id => false, :force => true do |t|
      t.integer :activity_id
      t.integer :aggregation_id
    end
    
    add_index :activities_aggregations, :aggregation_id
    add_index :activities_aggregations, :activity_id
    add_index :activities_aggregations, [:activity_id, :aggregation_id]
  end

  def self.down
    drop_table :activities_aggregations
  end
end