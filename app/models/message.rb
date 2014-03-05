class Message < ActiveRecord::Base
  belongs_to :user
  has_one :treenode, as: :obj

  validates :user_id, presence: true
  validate :user_id_exists
  validates :title, presence: true
  validates :text, presence: true

  private
    def user_id_exists
      errors.add(:user_id, "is invalid") unless User.exists?(self.user_id)
    end

end
