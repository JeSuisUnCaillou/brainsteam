require 'spec_helper'

describe Path do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
  let!(:threadhead) { FactoryGirl.create(:threadhead_and_friends) }
  
  before { @path = Path.new(user: user,
                               threadhead: threadhead,
                               treenode: threadhead.treenode) }

  subject { @path }

  it { should respond_to(:user) }
  it { should respond_to(:threadhead) }
  it { should respond_to(:treenode) }
  its(:user) { should eq user }
  its(:threadhead) { should eq threadhead }
  its(:treenode) { should eq threadhead.treenode }
 
  it { should be_valid } 


  describe "when the user is empty" do
    before { @path.user_id = nil }
    it { should_not be_valid }
  end

  describe "when the user doesn't exist" do
    before { @path.user_id = -1 }
    it { should_not be_valid }
  end

  describe "when the threadhead_id is empty" do
    before { @path.threadhead_id = nil }
    it { should_not be_valid }
  end

  describe "when the threadhead doesn't exist" do
    before { @path.threadhead_id = -1 }
    it { should_not be_valid }
  end

  describe "when the treenode_id is empty" do
    before { @path.treenode_id = nil }
    it { should_not be_valid }
  end

  describe "when the treenode doesn't exist" do
    before { @path.treenode_id = -1 }
    it { should_not be_valid }
  end

  describe "when a path with this treenode and user already exists" do
    before do
      p = FactoryGirl.create(:path, user: @path.user,
                                    treenode: @path.treenode,
                                    threadhead: @path.threadhead)
    end

    it { should_not be_valid }
  end

end
