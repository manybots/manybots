class CreateManybotsGmailEmails < ActiveRecord::Migration
  def change
    create_table :manybots_gmail_emails do |t|
      t.integer   :user_id
      t.string    :address
      t.integer   :muid
      t.text      :people
      t.text      :subject
      t.string    :tags
      t.datetime  :sent_at

      t.timestamps
    end
  end
end
