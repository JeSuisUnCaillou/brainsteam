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

  # has_one :first_message
  # has_one :user, -> through: :first_message

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
    first_message.try(:user)
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

  def treenodes_for_user(user_id)
    Treenode.joins(:paths)
            .where(paths: { threadhead_id: self.id,
                            user_id: user_id})
            .order('paths.created_at DESC')
  end

  def new_answers_for_user(user_id) 
    treenodes_opened = self.treenodes_for_user(user_id)
    
    if treenodes_opened.empty?
      return nil
    else
      tns_already_viewed = Treenode.where(parent_node_id: treenodes_opened)
                                 .joins('INNER JOIN paths 
                                         ON paths.treenode_id = treenodes.id')
                                 .where(paths: {user_id: user_id})
      if tns_already_viewed.empty?
        tns = Treenode.where(parent_node_id: treenodes_opened)
      else
        tns = Treenode.where(parent_node_id: treenodes_opened)
                      .where('id NOT IN (?)', tns_already_viewed.map{ |t| t.id })
      end
    end
  end

  def answers_count
    -1 + messages.count
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
