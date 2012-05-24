class CreateManybotsGooglecalendarEvents < ActiveRecord::Migration
  def change
    create_table :manybots_googlecalendar_events do |t|
      t.references :oauth_account
      t.string :remote_id
      t.datetime :remote_created_at
      t.datetime :remote_updated_at
      t.text :payload

      t.timestamps
    end
    add_index :manybots_googlecalendar_events, :oauth_account_id
  end
end
