require 'spec_helper'

describe Threadhead do

  before { @threadhead = Threadhead.new(private: false) }

  subject { @threadhead }

  it { should respond_to(:private) }
  it { should respond_to(:thread_tag_relationships) }  
  it { should respond_to(:thread_tags) }
  it { should respond_to(:link_tag!) }
  it { should respond_to(:unlink_tag!) }
  it { should respond_to(:treenode) }
  it { should respond_to(:first_message) }

  it { should be_valid }
  it { should_not be_private } # Default behaviour for v0.0

  describe "thread_tags associations" do
    
    before { @threadhead.save }

    let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
    before { @threadhead.link_tag!(thread_tag.id) }

    its(:thread_tags) { should eq [thread_tag] } # a changer des qu'on aura plus de 2 catégories

    it "destroy thread should destroy associated thread_tags" do
      ttrs = @threadhead.thread_tag_relationships.to_a
      @threadhead.destroy
      expect(ttrs).not_to be_empty
      ttrs.each do |ttr|
        expect(ThreadTagRelationship.where(id: ttr.id)).to be_empty 
      end
    end

    describe "unlink tags" do
      before { @threadhead.unlink_tag!(thread_tag.id) }
      its(:thread_tags) { should_not include(thread_tag) }  
    end

  end

  
  describe "treenode association" do
    before { @threadhead.save }
    let!(:thread_node) { FactoryGirl.create(:treenode, obj: @threadhead) } 
    its(:treenode) { should eq thread_node }

    describe "first_message 'association'" do
      let!(:message) { FactoryGirl.create(:message) }
      let!(:m_treenode) { FactoryGirl.create(:treenode, obj: message, parent_node: @threadhead.treenode) }
      its(:first_message) { should eq message }
    end
  end

end
