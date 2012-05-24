class CreateManybotsGithubRepositories < ActiveRecord::Migration
  def change
    create_table :manybots_github_repositories do |t|
      t.references :oauth_account
      t.string :slug
      t.integer :remote_id
      t.text :payload

      t.timestamps
    end
  end
end
