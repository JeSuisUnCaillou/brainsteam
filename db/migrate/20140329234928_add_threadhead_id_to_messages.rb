class AddThreadheadIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :threadhead_id, :integer
  end
end
