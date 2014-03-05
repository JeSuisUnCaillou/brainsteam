class Threadhead < ActiveRecord::Base

  default_scope -> { order('created_at DESC') }

  has_many :thread_tag_relationships, dependent: :destroy
  has_many :thread_tags, through: :thread_tag_relationships
  has_one :treenode, as: :obj

  def link_tag!(tag_id)
    thread_tag_relationships.create!(thread_tag_id: tag_id)
  end

  def unlink_tag!(tag_id)
    thread_tag_relationships.find_by(thread_tag_id: tag_id).destroy
  end
  
end
