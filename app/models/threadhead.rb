class Threadhead < ActiveRecord::Base

  default_scope -> { order('last_message_date DESC') }

  scope :sort_by_views, -> { joins(:treenode)
                             .joins('LEFT OUTER JOIN paths
                                     ON paths.treenode_id = treenodes.id')
                             .select('threadheads.*, count(paths.id) as paths_count')
                             .group('threadheads.id')
                             .reorder('paths_count DESC, last_message_date DESC') }

  scope :sort_by_answers, -> { joins(:messages)
                               .select('threadheads.*, count(messages.id) as m_count')
                               .group('threadheads.id')
                               .reorder('m_count DESC, last_message_date DESC') }

  before_create :set_last_message_date

  has_many :thread_tag_relationships, dependent: :destroy
  has_many :thread_tags, through: :thread_tag_relationships
  has_one :treenode, as: :obj
  has_many :paths, dependent: :destroy
  has_many :messages

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

  def paths_by_user(user_id)
    paths.where(user_id: user_id)
  end

  def answers_count
    -1 + Message.where(threadhead_id: id).count
  end

  def views_count
    treenode.paths.count
  end

  def self.create_with_friends(privat, message, thread_tag_id, user)
    @threadhead = Threadhead.new(private: privat)

    if @threadhead.save
      @message = Message.new(text: message[:text],
                             title: message[:title],
                             user: user, 
                             threadhead: @threadhead)
      if @message.save
        @thread_node = Treenode.create(obj: @threadhead)
        @message_node = Treenode.create(obj: @message, parent_node: @thread_node)
        @threadhead.link_tag!(thread_tag_id) # a changer dès qu'on aura plus de tags
        return @threadhead
      else
        @threadhead.destroy
        return nil
      end
    else
      return nil
    end
   
  end
 
  def set_last_message_date
    self.last_message_date = DateTime.now
  end

end
