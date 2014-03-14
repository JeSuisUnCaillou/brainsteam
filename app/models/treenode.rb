class Treenode < ActiveRecord::Base
  belongs_to :parent_node, class_name: "Treenode", foreign_key: :parent_node_id
  has_many :children_nodes, class_name: "Treenode", foreign_key: :parent_node_id,
                                                    dependent: :destroy 

  belongs_to :obj, polymorphic: true, dependent: :destroy

  has_many :paths

  validates :obj, presence: true
  validates :obj_id, uniqueness: { scope: :obj_type }
  validate :obj_exists
  validate :parent_node_exists

  def nodes_count
    1 + children_nodes.map{ |n| n.nodes_count }.sum
  end

  def paths_count
    paths.count
  end

  private
    def obj_exists
      if self.obj_type == Threadhead.to_s
        errors.add(:obj_id, "is invalid") unless Threadhead.exists?(self.obj_id)
      elsif self.obj_type = Message.to_s
        errors.add(:obj_id, "is invalid") unless Message.exists?(self.obj_id)  
      else
        errors.add(:obj_type, "is invalid")
      end
    end
    
    def parent_node_exists
      if self.obj_type == Message.to_s
        errors.add(:parent_node_id, "is invalid") unless Treenode.exists?(self.parent_node_id)
      end
    end 
end
