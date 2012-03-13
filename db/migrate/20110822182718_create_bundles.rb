class CreateBundles < ActiveRecord::Migration
  def self.up
    create_table :bundles do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :slug

      t.timestamps
    end
  end

  def self.down
    drop_table :bundles
  end
end
