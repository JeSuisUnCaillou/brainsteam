class CreateThreadheads < ActiveRecord::Migration
  def change
    create_table :threadheads do |t|
      t.boolean :private, default: false

      t.timestamps
    end
  end
end
