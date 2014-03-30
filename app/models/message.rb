class Message < ActiveRecord::Base
  belongs_to :user
  has_one :treenode, as: :obj
  belongs_to :threadhead

  validates :user_id, presence: true
  validate :user_id_exists

  validates :threadhead_id, presence: true
  validate :threadhead_id_exists

  validates :title, presence: true
  validates :text, presence: true

  def answers_count
    treenode.children_nodes.count
  end

  def views_count
    treenode.paths.count
  end

  def children_messages
    @messages = Message.joins(:treenode)
                       .where(treenodes: { parent_node_id: treenode.id })
    return @messages
  end


  def self.create_with_friends(title, text, user, parent_node_id, threadhead_id)
     @threadhead = Threadhead.find(threadhead_id) 
     @message = Message.new(title: title,
                            text: text,
                            user: user,
                            threadhead_id: threadhead_id)

     if !@threadhead.nil? && @message.save
       @treenode = Treenode.new(obj: @message, parent_node_id: parent_node_id)
      
       if @treenode.save
         @threadhead.last_message_date = DateTime.now
         @threadhead.save
         return @message
       else
         @message.destroy
         return nil
       end

     else
       return nil
     end
  end

  private
    def user_id_exists
      errors.add(:user_id, "is invalid") unless User.exists?(self.user_id)
    end

    def threadhead_id_exists
      errors.add(:threadhead_id, "is invalid") unless Threadhead.exists?(self.threadhead_id)
    end

end
