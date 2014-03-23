class Path < ActiveRecord::Base
  belongs_to :user
  belongs_to :threadhead
  belongs_to :treenode
  
  validates :user_id, presence: true
  validates :threadhead_id, presence: true
  validates :treenode_id, presence: true
  validates :treenode_id, uniqueness: { scope: :user_id }

  validate :user_id_exists
  validate :threadhead_id_exists
  validate :treenode_id_exists

  
  def children_paths
    Path.where(threadhead_id: self.threadhead_id, user_id: self.user_id)
        .includes(:treenode) # includes instead of joins for not read-only records
        .where(treenodes: { parent_node_id: self.treenode_id })
  end


  def destroy_with_children_paths
    paths = self.children_paths
    paths.each do |p|
      p.destroy_with_children_paths
    end
    self.destroy
  end
  
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
