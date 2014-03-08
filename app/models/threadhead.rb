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

  def first_message
    treenode.nil? ? nil : treenode.children_nodes.first.obj
  end

  def user
    first_message.nil? ? nil : first_message.user
  end

  def title 
    first_message.nil? ? nil : first_message.title
  end

  def text
    first_message.nil? ? nil : first_message.text
  end

  def self.create_with_friends(privat, message, thread_tag_id, user)
    @threadhead = Threadhead.new(private: privat)
    @message = Message.new(text: message[:text],
                           title: message[:title],
                           user: user)
    if @message.save && @threadhead.save
      #@threadhead.save
      @thread_node = Treenode.create(obj: @threadhead)
      @message_node = Treenode.create(obj: @message, parent_node: @thread_node)
      @threadhead.link_tag!(thread_tag_id) # a changer dès qu'on aura plus de tags
      return @threadhead
    else
      return nil
    end   
  end
 
end
