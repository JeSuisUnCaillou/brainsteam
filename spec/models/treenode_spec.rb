require 'spec_helper'

describe Treenode do

  let!(:threadhead) { FactoryGirl.create(:threadhead) }
  let!(:message) { FactoryGirl.create(:message) }
  let!(:parent_node) { FactoryGirl.create(:treenode, obj: threadhead) }
  before do
    @treenode = Treenode.new( obj: message, parent_node: parent_node )
  end

  subject { @treenode }

  it { should respond_to(:obj_type) }
  it { should respond_to(:obj_id) }
  it { should respond_to(:parent_node_id) }
  it { should respond_to(:parent_node) }
  it { should respond_to(:children_nodes) }
  it { should respond_to(:obj) }
  its(:parent_node) { should eq parent_node }

  it { should be_valid }

  describe "when obj_id is not present" do
    before { @treenode.obj_id = nil }
    it { should_not be_valid }
  end

  describe "when obj_type is not present" do 
    before { @treenode.obj_type = nil }
    it { should_not be_valid }
  end

  describe "when a node with this obj already exists" do
    before do
      tn = FactoryGirl.create(:treenode, obj: @treenode.obj, parent_node: parent_node)
      #tn.save  c'est déjà apparemment save par factorygirl
    end
    it { should_not be_valid }
  end
  
  describe "node-threadhead association" do
    before { @treenode.obj = threadhead }
 
    its(:obj_id) { should eq threadhead.id }
    its(:obj_type) { should eq Threadhead.to_s }
    its(:obj) { should eq threadhead }

    describe "when obj_id doesn't exist in Threadhead" do
      before { @treenode.obj_id = -1 }
      it { should_not be_valid }
    end
  end

  describe "node-message association" do
    before { @treenode.obj = message }

    its(:obj_id) { should eq message.id }
    its(:obj_type) { should eq Message.to_s }
    its(:obj) { should eq message }

    describe "when obj_id doesn't exist in Message" do
      before { @treenode.obj_id = -1 }
      it { should_not be_valid }
    end
  end

  describe "parent-children nodes associations" do
    before { @treenode.save }
    let!(:m_1) { FactoryGirl.create(:message) }
    let!(:m_2) { FactoryGirl.create(:message) }
    let!(:m_3) { FactoryGirl.create(:message) }
    let!(:n_1) { FactoryGirl.create(:treenode, obj: m_1, parent_node: @treenode) } 
    let!(:n_2) { FactoryGirl.create(:treenode, obj: m_2, parent_node: @treenode) }
    let!(:n_3) { FactoryGirl.create(:treenode, obj: m_3, parent_node: @treenode) }
   
    its(:children_nodes) { should eq [n_1, n_2, n_3] } 
    
    describe "when parent_id is not present" do
      before { @treenode.parent_node_id = nil }

      describe "and obj_type = 'Threadhead'" do
        let!(:th) { FactoryGirl.create(:threadhead) }
        before do
          @treenode.obj = th
        end
        it { should be_valid }
      end

      describe "and obj_type = 'Message'" do
         before { @treenode.obj = message }
         it { should_not be_valid }
      end
    end

  end

end
