class Path < ActiveRecord::Base
  belongs_to :user
  belongs_to :threadhead
  belongs_to :treenode
  
  validates :user_id, presence: true
  validates :threadhead_id, presence: true
  validates :treenode_id, presence: true

  validate :user_id_exists
  validate :threadhead_id_exists
  validate :treenode_id_exists
  
  private
    def user_id_exists
      errors.add(:user_id, "is invalid") unless User.exists?(self.user_id)
    end

    def threadhead_id_exists
      errors.add(:threadhead_id, "is invalid") unless Threadhead.exists?(self.threadhead_id)
    end

    def treenode_id_exists
      errors.add(:treenode_id, "is invalid") unless Treenode.exists?(self.treenode_id)
    end


end
