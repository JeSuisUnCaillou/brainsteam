class MessageBuilder

  include ActiveModel::Model
  attr_accessor :title, :text, :user, :threadhead, :parent_node
  attr_reader :message, :message_node

  validate :built_attributes_validation

  def initialize(attributes={})
    super

    @message = Message.new(title: @title,
                           text: @text,
                           user: @user,
                           threadhead: @threadhead)
    @message_node = Treenode.new(obj: @message, parent_node: @parent_node)
  end


  def save
    ActiveRecord::Base.transaction do
      @message.save!
      @message_node.save!
    end
    
  end  


  private

    def built_attributes_validation

      errors.add(:parent_node, "is invalid") unless !@parent_node.nil? && 
                                                    @parent_node.valid?
      unless @message.valid?
        @message.errors.each do |error|
          errors.add(:message, error)
        end
      end

    end

end
