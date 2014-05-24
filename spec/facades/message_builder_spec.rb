require 'spec_helper'

describe MessageBuilder do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
  let!(:threadhead) { FactoryGirl.create(:threadhead_and_friends) }

  before do
    @message_builder = MessageBuilder.new(title: "title",
                                          text: "text",
                                          user: user,
                                          threadhead: threadhead,
                                          parent_node: threadhead.first_message.treenode)
  end
 
  subject { @message_builder }

  it { should be_valid }
  it { should respond_to(:title) }
  it { should respond_to(:text) }
  it { should respond_to(:user) }
  it { should respond_to(:threadhead) }
  it { should respond_to(:parent_node) }

  it { should respond_to(:message) }
  it { should respond_to(:message_node) }
  its(:message) { should be_valid }
  its(:message_node) { should_not be_valid }#'cause message not persisted


  describe "when the built message is very invalid" do
    before do  
      @message_builder = MessageBuilder.new(title: "",
                                          text: "",
                                          user: nil,
                                          threadhead: nil,
                                          parent_node: threadhead.first_message.treenode)
    end
    
    it { should_not be_valid }
    it "should have 6 message errors" do
      @message_builder.should have(6).errors_on(:message)
      @message_builder.should have(:no).errors_on(:parent_node)
    end 

  end


  describe "when the parent_node attribute is invalid" do
    before do 
      @message_builder = MessageBuilder.new(title: "title",
                                          text: "text",
                                          user: user,
                                          threadhead: threadhead,
                                          parent_node: nil)
    end

    it { should_not be_valid }
    it "should have 6 message errors" do
      @message_builder.should have(:no).errors_on(:message)
      @message_builder.should have(1).errors_on(:parent_node)
    end

  end


  describe "saving the builder" do
    before { @message_builder.save }

    it "should save the message" do 
      @message_builder.message.should be_persisted
    end

    it "should save the message_node" do 
      @message_builder.message_node.should be_persisted
    end
  
  end

end


