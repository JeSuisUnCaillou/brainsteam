class CreateThreadTagRelationships < ActiveRecord::Migration
  def change
    create_table :thread_tag_relationships do |t|
      t.integer :threadhead_id
      t.integer :thread_tag_id

      t.timestamps
    end
  end
end
