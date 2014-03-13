require 'spec_helper'

describe Message do
  let!(:user) { FactoryGirl.create(:user) }
  before { @message = FactoryGirl.create(:message, user: user,
                                                   title: "Titre",
                                                   text: "contenu...") }

  subject { @message }

  it { should respond_to(:title) }
  it { should respond_to(:text) }
  it { should respond_to(:user_id) }
  it { should respond_to(:treenode) }
  it { should respond_to(:user) }
  it { should respond_to(:answers_count) } #write right spec
  it { should respond_to(:children_messages) }
  its(:user) { should eq user }

  it { should be_valid }

  describe "when user_id is empty" do
    before { @message.user_id = nil }
    it { should_not be_valid }
  end

  describe "when user doesn't exist" do
    before { @message.user_id = -1 }
    it { should_not be_valid }
  end

  describe "when title is empty" do
    before { @message.title = nil }
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
                                             @threadhead.first_message.treenode.id)
    end
 
    subject { @message }
    it { should be_valid }
    its(:treenode) { should_not eq nil }

    describe "children_messages method" do
      before do
        @m_1 = Message.create_with_friends('m1', 't1',
                                           @threadhead.user,
                                           @message.treenode.id)
        @m_2 = Message.create_with_friends('m2', 't2',
                                           @threadhead.user,
                                           @message.treenode.id) 
      end
      its(:children_messages) { should eq [@m_1, @m_2] }
    end

  end

end
