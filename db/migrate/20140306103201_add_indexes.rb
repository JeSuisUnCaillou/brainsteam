class AddIndexes < ActiveRecord::Migration
  def change
    add_index :users, :name, unique: true
    add_index :thread_tag_relationships, :threadhead_id
    add_index :thread_tag_relationships, :thread_tag_id
    add_index :thread_tags, :name, unique: true
    add_index :treenodes, [:obj_id, :obj_type], unique: true
    add_index :treenodes, :parent_node_id
    add_index :messages, :user_id
  end
end
