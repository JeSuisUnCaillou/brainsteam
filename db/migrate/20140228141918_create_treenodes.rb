class CreateTreenodes < ActiveRecord::Migration
  def change
    create_table :treenodes do |t|
      t.references :obj, polymorphic: true
      t.integer :parent_node_id

      t.timestamps
    end
  end
end
