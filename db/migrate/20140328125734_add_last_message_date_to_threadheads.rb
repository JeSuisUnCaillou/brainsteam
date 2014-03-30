class AddLastMessageDateToThreadheads < ActiveRecord::Migration
  def change
    add_column :threadheads, :last_message_date, :datetime
  end
end
