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

end
