class AddPathsIndexes < ActiveRecord::Migration
  def change
    add_index :paths, [:threadhead_id, :user_id]
    add_index :paths, [:treenode_id, :user_id], unique: true
    add_index :paths, :user_id # pas sur que celui là serve
  end
end
