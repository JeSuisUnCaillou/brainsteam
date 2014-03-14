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
  it { should respond_to(:paths) }
  it { should respond_to(:paths_count) }
  it { should respond_to(:nodes_count) }
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

  describe "parent-children and node-object associations" do
    before { @treenode.save }
    let!(:m_1) { FactoryGirl.create(:message) }
    let!(:m_2) { FactoryGirl.create(:message) }
    let!(:m_3) { FactoryGirl.create(:message) }
    let!(:n_1) { FactoryGirl.create(:treenode, obj: m_1, parent_node: @treenode) } 
    let!(:n_2) { FactoryGirl.create(:treenode, obj: m_2, parent_node: @treenode) }
    let!(:n_3) { FactoryGirl.create(:treenode, obj: m_3, parent_node: @treenode) }
    let!(:m_11) { FactoryGirl.create(:treenode, parent_node: n_1) }
     
    its(:children_nodes) { should eq [n_1, n_2, n_3] } 

    its(:nodes_count) { should eq 5 }

    describe "destroy the node" do
      before { @treenode.destroy }
     
      it "should destroy it's object" do
        expect(Message.where(id: message.id)).to eq []
      end 
     
      it "should destroy it's children" do
        expect(Treenode.where(id: [n_1, n_2, n_3])).to eq []
      end

      it "should destroy it's children's objects" do
        expect(Message.where(id: [m_1, m_2, m_3])).to eq []
      end

      it "should destroy it's children's chidren" do
        expect(Treenode.where(id: m_11)).to eq []
      end
    end
    
    describe "when parent_id is not present" do
      before { @treenode.parent_node_id = nil }

      describe "and obj_type = 'Threadhead'" do
        let!(:th) { FactoryGirl.create(:threadhead) }
        before { @treenode.obj = th }
        it { should be_valid }
      end

      describe "and obj_type = 'Message'" do
         before { @treenode.obj = message }
         it { should_not be_valid }
      end

    end

    describe "paths association" do

      let!(:reader_1) { FactoryGirl.create(:user) }
      let!(:reader_2) { FactoryGirl.create(:user) }
      let!(:path_1) { FactoryGirl.create(:path, user: reader_1,
                                              threadhead: threadhead,
                                              treenode: @treenode) }
      let!(:path_2) { FactoryGirl.create(:path, user: reader_2,
                                              threadhead: threadhead,
                                              treenode: @treenode) }
      its(:paths) { should eq [path_1, path_2] }
      its(:paths_count) { should eq 2 }
    end

  end

end
