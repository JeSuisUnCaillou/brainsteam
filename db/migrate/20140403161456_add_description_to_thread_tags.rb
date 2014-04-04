class AddDescriptionToThreadTags < ActiveRecord::Migration
  def change
    add_column :thread_tags, :description, :text
  end
end
