class CreateThreadTags < ActiveRecord::Migration
  def change
    create_table :thread_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
