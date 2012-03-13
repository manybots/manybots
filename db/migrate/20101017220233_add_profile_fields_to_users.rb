class AddProfileFieldsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :name, :string
    add_column :users, :avatar_source, :string
    add_column :users, :avatar_url, :string
    add_column :users, :country, :string
    add_column :users, :is_first_login, :boolean, :default => true
    add_column :users, :authentication_token, :string
  end

  def self.down
    remove_column :users, :country
    remove_column :users, :avatar_url
    remove_column :users, :avatar_source
    remove_column :users, :name
    remove_column :users, :is_first_login
    remove_column :users, :authentication_token
  end
end
