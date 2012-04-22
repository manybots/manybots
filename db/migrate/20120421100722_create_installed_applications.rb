class CreateInstalledApplications < ActiveRecord::Migration
  def change
    create_table :installed_applications do |t|
      t.references :user
      t.references :client_application
      t.boolean :in_menu, :default => false
      t.boolean :in_library, :default => false
      t.boolean :is_default, :default => false

      t.timestamps
    end
    add_index :installed_applications, :user_id
    add_index :installed_applications, :client_application_id
  end
end
