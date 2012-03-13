class CreateOauthAccounts < ActiveRecord::Migration
  def change
    create_table :oauth_accounts do |t|
      t.integer :client_application_id
      t.integer :user_id
      t.string  :token
      t.string  :secret
      t.string  :remote_account_id
      t.text    :payload

      t.timestamps
    end
  end
end
