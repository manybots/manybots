class CreateAggregationsNotificationsTable < ActiveRecord::Migration
  def self.up
    create_table :aggregations_notifications, :id => false, :force => true do |t|
      t.integer :aggregation_id
      t.integer :notification_id
    end
  end

  def self.down
    drop_table :aggregations_notifications
  end
end
