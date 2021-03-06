require 'spec_helper'

describe Message do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
  let!(:threadhead) { FactoryGirl.create(:threadhead_and_friends) }
  before { @message = FactoryGirl.create(:message, user: user,
                                                   title: "a"*140,
                                                   text: "contenu...",
                                                   threadhead: threadhead) }

  subject { @message }

  it { should respond_to(:title) }
  it { should respond_to(:text) }
  it { should respond_to(:user_id) }
  it { should respond_to(:treenode) }
  it { should respond_to(:user) }
  it { should respond_to(:children_messages) }
  it { should respond_to(:threadhead) }
  it { should respond_to(:answers_count) }
  it { should respond_to(:views_count) }
 
  its(:user) { should eq user }
  its(:threadhead) { should eq threadhead }

  it { should be_valid }

  describe "when user_id is empty" do
    before { @message.user_id = nil }
    it { should_not be_valid }
  end

  describe "when user doesn't exist" do
    before { @message.user_id = -1 }
    it { should_not be_valid }
  end


  describe "when threadhead_id is empty" do
    before { @message.threadhead_id = nil }
    it { should_not be_valid }
  end

  describe "when threadhead doesn't exist" do
    before { @message.threadhead_id = -1 }
    it { should_not be_valid }
  end


  describe "when title is empty" do
    before { @message.title = nil }
    it { should_not be_valid }
  end

  describe "when title is longer than 140 char" do
    before { @message.title = "a"*141 }
    it { should_not be_valid }
  end

  describe "when text is empty" do
    before { @message.text = nil }
    it { should_not be_valid }
  end


  describe "treenode association" do
    before { @message.save }
    let!(:threadhead) { FactoryGirl.create(:threadhead) }
    let!(:thread_node) { FactoryGirl.create(:treenode, obj: threadhead) } 
    let!(:node) { FactoryGirl.create(:treenode, obj: @message, parent_node: thread_node) }

    its(:treenode) { should eq node }
  end

  describe "create_with_friends method" do
    let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
    let!(:user) { FactoryGirl.create(:user) }
    before do
      @threadhead = Threadhead.create_with_friends(false,
                                                   {title: 'title', text: 'text'},
                                                   thread_tag.id,
                                                   user)
      @message = Message.create_with_friends('title',
                                             'text', 
                                             @threadhead.user, 
                                             @threadhead.first_message.treenode.id,
                                             @threadhead.id)
    end
 
    subject { @message }
    it { should be_valid }
    its(:treenode) { should_not eq nil }

    describe "children_messages method" do
      before do
        @m_1 = Message.create_with_friends('m1', 't1',
                                           @threadhead.user,
                                           @message.treenode.id,
                                           @threadhead.id)
        @m_2 = Message.create_with_friends('m2', 't2',
                                           @threadhead.user,
                                           @message.treenode.id,
                                           @threadhead.id) 
      end
      its(:children_messages) { should eq [@m_1, @m_2] }
      its(:answers_count) { should eq 2 }
    end

  end

end
