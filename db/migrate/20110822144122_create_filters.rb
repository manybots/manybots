class CreateFilters < ActiveRecord::Migration
  def self.up
    create_table :filters do |t|
      t.integer :user_id
      t.string :name
      t.string :slug
      t.string :tag_list
      t.text :description
      t.text :payload

      t.timestamps
    end
  end

  def self.down
    drop_table :filters
  end
end
