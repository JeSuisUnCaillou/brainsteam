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
  it { should respond_to(:children_paths) }
  it { should respond_to(:desactivate_with_children_paths) }
  it { should respond_to(:active) }
  its(:user) { should eq user }
  its(:threadhead) { should eq threadhead }
  its(:treenode) { should eq threadhead.treenode }
  its(:active) { should eq true }

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

  describe "children_paths" do
    before { @path.save }
    let!(:message) { FactoryGirl.create(:message_and_friends, user: user,
                                                              threadhead: threadhead) }
    let!(:m1_path) { FactoryGirl.create(:path, user: user,
                                            threadhead: threadhead,
                                            treenode: threadhead.first_message.treenode) }
    let!(:m2_path) { FactoryGirl.create(:path, user: user,
                                            threadhead: threadhead,
                                            treenode: message.treenode) }

    its(:children_paths) { should eq [m1_path, m2_path] }

    describe "desactivate_with_children_paths method" do
      before { @path.desactivate_with_children_paths }
      it "should desactivate children paths" do
        expect(Path.where(id: [m1_path, m2_path])).to eq []
      end
    end

  end




  describe "create_or_reactivate metod" do

    
    describe "when no desactivated path exists" do

       it "checking this path doesn't exists" do
         expect(Path.where(user_id: user.id,
                        threadhead_id: threadhead.id,
                        treenode_id: threadhead.first_message.treenode.id)).to eq [] 
       end

       describe "calling the method" do

         before do
           @new_path = Path.create_or_reactivate(user.id,
                                          threadhead.id,
                                          threadhead.first_message.treenode.id)
         end

         it "should create a new path" do
           expect(Path.where(user_id: user.id,
                          threadhead_id: threadhead.id,
                          treenode_id: threadhead.first_message.treenode.id))
                  .to eq [@new_path] 
         end

       end
      
      
    end
 
    describe "when a desactivated path already exists" do

      before do
        @old_path = Path.create(user_id: user.id,
                                threadhead_id: threadhead.id,
                                treenode_id: threadhead.first_message.treenode.id,
                                active: false)
      end

       it "checking this desactivated path exists" do
         expect(Path.where(user_id: user.id,
                        threadhead_id: threadhead.id,
                        treenode_id: threadhead.first_message.treenode.id,
                        active: false))
                .to eq [@old_path] 
       end
 
       describe "calling the method" do
         before do
           @new_path = Path.create_or_reactivate(user.id,
                                          threadhead.id,
                                          threadhead.first_message.treenode.id)
         end

         it "should reactivate the path" do
           expect(Path.where(user_id: user.id,
                          threadhead_id: threadhead.id,
                          treenode_id: threadhead.first_message.treenode.id,
                          active: true))
                  .to eq [@new_path] 
         end
         
       end

    end

  end

  
  describe "scopes" do
    
     let!(:user_1) { FactoryGirl.create(:user) }
     let!(:user_2) { FactoryGirl.create(:user) }
     let!(:path_1) { Path.create(user: user_1,
                               threadhead: threadhead,
                               treenode: threadhead.treenode) }
     let!(:path_11) { Path.create(user: user_1,
                               threadhead: threadhead,
                               treenode: threadhead.first_message.treenode,
                               active: false) }
     let!(:path_2) { Path.create(user: user_2,
                               threadhead: threadhead,
                               treenode: threadhead.treenode) }
     let!(:path_21) { Path.create(user: user_2,
                               threadhead: threadhead,
                               treenode: threadhead.first_message.treenode) }

     it "default scope should filter desactivated paths" do
       threadhead.paths.should eq [path_1, path_2, path_21]
     end

     it "'by_user' should filter by user" do
       threadhead.paths.by_user(user_1).should eq [path_1]
       threadhead.paths.by_user(user_2).should eq [path_2, path_21]
     end
     
     it "'desactivated' should return desactivated paths" do
        threadhead.paths.desactivated.should eq [path_11]
     end
  end

end
