class CreateAggregations < ActiveRecord::Migration
  def self.up
    create_table :aggregations do |t|
      t.integer :user_id
      t.string :name
      t.string :type_string
      t.integer :total
      t.string :object_type
      t.string :avatar_url
      t.string :path

      t.timestamps
    end
  end

  def self.down
    drop_table :aggregations
  end
end
