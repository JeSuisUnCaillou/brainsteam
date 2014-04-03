class AddActiveToPaths < ActiveRecord::Migration
  def change
    add_column :paths, :active, :boolean, default: true
  end
end
