require 'spec_helper'

describe Threadhead do

  before { @threadhead = Threadhead.new(private: false) }

  subject { @threadhead }

  it { should respond_to(:private) }
  it { should respond_to(:thread_tag_relationships) }  
  it { should respond_to(:thread_tags) }
  it { should respond_to(:paths) }
  it { should respond_to(:paths_by_user) }
  it { should respond_to(:link_tag!) }
  it { should respond_to(:unlink_tag!) }
  it { should respond_to(:treenode) }
  it { should respond_to(:first_message) }
  it { should respond_to(:user) }
  it { should respond_to(:title) }
  it { should respond_to(:text) }
  it { should respond_to(:answers_count) } #write right spec


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


  describe "create_with_friends method" do
     let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
     let!(:user) { FactoryGirl.create(:user) }
     before do
       @threadhead = Threadhead.create_with_friends(false,
                                                   { title: 'title', text: 'text'},
                                                   thread_tag.id,
                                                   user)
     end

     subject { @threadhead }

     it { should be_valid }    
     its(:first_message) { should_not eq nil }
     its(:thread_tags) { should_not eq nil }
     its(:user) { should eq user }
     its(:title) { should eq 'title' }
     its(:text) { should eq 'text' }

     
    describe "paths association" do
      let!(:reader) { FactoryGirl.create(:user) }
      let!(:path_1) { FactoryGirl.create(:path, user: reader,
                                             threadhead: @threadhead,
                                             treenode: @threadhead.treenode) }
      let!(:path_2) { FactoryGirl.create(:path, user: @threadhead.user,
                                             threadhead: @threadhead,
                                             treenode: @threadhead.treenode) }

      let!(:path_3) { FactoryGirl.create(:path, user: @threadhead.user,
                                             threadhead: @threadhead,
                                             treenode: @threadhead.first_message.treenode) }
    
      its(:paths) { should eq [path_1, path_2, path_3] }
      
      describe "paths_by_user method" do
        it "with a reader" do
          @threadhead.paths_by_user(reader.id).should eq [path_1]
        end
        it "with the author" do
          @threadhead.paths_by_user(user.id).should eq [path_2, path_3]
        end 
      
      end

    end


  end
end
