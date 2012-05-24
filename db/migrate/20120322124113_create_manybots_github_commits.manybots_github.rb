class CreateManybotsGithubCommits < ActiveRecord::Migration
  def change
    create_table :manybots_github_commits do |t|
      t.references :repository
      t.text :message
      t.string :sha
      t.text :payload

      t.timestamps
    end
    add_index :manybots_github_commits, :repository_id
  end
end
