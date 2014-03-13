class Message < ActiveRecord::Base
  belongs_to :user
  has_one :treenode, as: :obj

  validates :user_id, presence: true
  validate :user_id_exists
  validates :title, presence: true
  validates :text, presence: true


  def children_messages
    @messages = Message.joins(:treenode)
                       .where(treenodes: { parent_node_id: treenode.id })
    return @messages
  end

  def answers_count
    -1 + treenode.nodes_count # a changer par ~ -1 + Path.count(threadhead_id: id)
  end

  def self.create_with_friends(title, text, user, parent_node_id) # rajouter la création de paths
     @message = Message.new(title: title, text: text, user: user)

     if @message.save
       @treenode = Treenode.new(obj: @message, parent_node_id: parent_node_id)

       if @treenode.save
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

end
