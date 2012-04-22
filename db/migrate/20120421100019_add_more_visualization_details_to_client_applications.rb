class AddMoreVisualizationDetailsToClientApplications < ActiveRecord::Migration
  def change
    add_column :client_applications, :target_objects, :string
    add_column :client_applications, :in_library, :boolean
    add_column :client_applications, :in_menu, :boolean
  end
end
