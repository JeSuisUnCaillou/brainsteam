class ThreadheadBuilder

  include ActiveModel::Model
  attr_accessor :title, :text, :thread_tag_id, :privat, :user
  attr_reader :threadhead, :thread_node, :message, :message_node

  validate :built_objects_validation

  def save
    @threadhead = Threadhead.new(private: @privat)

    if @threadhead.save
      @message = Message.new(text: @text,
                             title: @title,
                             user: @user, 
                             threadhead: @threadhead)
      if @message.save
        @thread_node = Treenode.create(obj: @threadhead)
        @message_node = Treenode.create(obj: @message, parent_node: @thread_node)
        @threadhead.link_tag!(@thread_tag_id)
      else
        @threadhead.destroy
      end
    else
      #rien
    end

  end
 

  private

    def built_objects_validation
      errors.add(:message, "is invalid") unless !@message.nil? && @message.valid?
    end 
end
