class CreatePaths < ActiveRecord::Migration
  def change
    create_table :paths do |t|
      t.integer :user_id
      t.integer :threadhead_id
      t.integer :treenode_id

      t.timestamps
    end
  end
end
