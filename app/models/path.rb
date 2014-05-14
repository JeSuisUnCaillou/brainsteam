class Path < ActiveRecord::Base

  default_scope -> { where(active: true) }
  
  scope :desactivated, -> { where(active: false) }

  scope :by_user, -> (usr){ where("user_id = ?", usr) }

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


  def self.create_or_reactivate(user_id, threadhead_id, treenode_id)
    path = Path.find_by(user_id: user_id,
                      threadhead_id: threadhead_id,
                      treenode_id: treenode_id,
                      active: false)
    if path.nil?
      path = Path.create(user_id: user_id,
                      threadhead_id: threadhead_id,
                      treenode_id: treenode_id,
                      active: true)
    else
      path.active = true
      path.save
    end

    return path.valid? ? path : nil
  end


  def desactivate_with_children_paths
    paths = self.children_paths
    paths.each do |p|
      p.desactivate_with_children_paths
    end
    self.active = false
    self.save
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
