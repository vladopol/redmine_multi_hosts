class AddMultiHostToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :multi_host_id, :integer, null: true
    add_index :projects, :multi_host_id
  end
end
