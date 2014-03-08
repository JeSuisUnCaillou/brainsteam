require 'spec_helper'

describe "Threadhead Pages" do
  
  subject { page }

  before(:all) { 2.times { FactoryGirl.create(:thread_tag) } } # a changer quand on aura plus de thread_tags
  after(:all) { ThreadTag.delete_all }


  describe "index" do
    
    before(:all) { 32.times { FactoryGirl.create(:threadhead_and_friends) } }
    after(:all) { Threadhead.delete_all
                  ThreadTagRelationship.delete_all
                  Treenode.delete_all
                  Message.delete_all
                  User.delete_all }
      
    before { visit threadheads_path }

    it { should have_title('All threads') }
    it { should have_link('New thread', href: new_threadhead_path) }

    let(:first_threadhead) { Threadhead.first }

    describe "filters" do
      describe "ascending filter" do
        before do
           select 'ascending', from: 'Creation time'
           click_button('Filter')
        end
        it { should_not have_selector("tr.threadhead", text: first_threadhead.first_message.title) }
        it { should have_selector("tr.threadhead", text: Threadhead.last.first_message.title) }
      end
      
      describe "tag filters" do        
        before do
          uncheck ThreadTag.first.name
          click_button 'Filter'
        end        
        it { should_not have_selector("tr.threadhead") }
        
        describe "all tags unchecked" do
          before do
            uncheck ThreadTag.last.name
            click_button 'Filter'
          end
          it { should have_selector('tr.threadhead') }
        end
      end
    end
 
    describe "first line attributes" do
      it { should have_selector('tr.threadhead/td.thread_tags/div', 
                                text: first_threadhead.thread_tags.first.name) }
      it { should have_link('view thread', href: threadhead_path(first_threadhead)) }
      it { should have_selector('tr.threadhead', text: first_threadhead.first_message.title) }
      it { should have_selector('tr.threadhead', text: first_threadhead.user.name) }
    end

    describe "pagination" do
      it { should have_selector('div.pagination') }

      it "should list each thread" do
        Threadhead.paginate(page: 1).each do |threadhead|
          expect(page).to have_selector("tr.threadhead", text: threadhead.first_message.title)
        end
      end
    end

    describe "delete links" do

      describe "as an unknown visitor" do
        it { should_not have_link('delete') }
        
        describe "submitting a DELETE request to the Threadhead#destroy action" do
          before { delete threadhead_path(Threadhead.first) }
          specify { response.should redirect_to(signin_path) }
        end
      end

      describe "as a non admin user" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          sign_in user
          visit threadheads_path
        end
        it { should_not have_link('delete') }

        describe "submitting a DELETE request to the Threadhead#destroy action" do
          before { delete threadhead_path(Threadhead.first) }
          specify { response.should redirect_to(signin_path) }
        end
      end
    
      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        
        before do 
          sign_in admin
          visit threadheads_path
        end
        
        it { should have_link('delete') }

        it "should be able to delete a thread" do
          expect do
             click_link('delete', match: :first)
          end.to change(Threadhead, :count).by(-1)
        end

      end
    end
  end
  
  describe "thread show page" do
    let!(:thread_tag) { ThreadTag.first }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:threadhead) { Threadhead.create_with_friends false,
                                                       {title: 'title', text: 'text'},
                                                       thread_tag.id,
                                                       user }
    before { visit threadhead_path(threadhead) }
 
    it { should have_title(threadhead.first_message.title) }
    it { should have_content(thread_tag.name) } # a changer quand on aura plus de tags
    it { should have_content(threadhead.first_message.title) }
    it { should have_content(threadhead.first_message.text) }
    it { should have_content(threadhead.user.name) } 
  end

  describe "new thread page" do    
    
    describe "as a logged in user" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        sign_in user
        visit new_threadhead_path
      end
      
      it { should have_title('New thread') }
      it { should have_content('New Thread') }
      it { should have_content(ThreadTag.first.name) } # a changer quand on aura d'autres catégories
      it { should have_content(ThreadTag.last.name) }

      describe "creating a new thread with empty fields" do 
        it "should not create a new thread" do
          expect { click_button('Create thread') }.not_to change(Threadhead, :count)
        end
        
      end

      describe "creating a new thread" do
        before do
           fill_in :threadhead_message_title, with: 'my title'
           fill_in :threadhead_message_text, with: 'my idea'
        end
        
        it "should be able to create a new thread" do
          expect { click_button('Create thread') }.to change(Threadhead, :count).by(1)
        end
      
        it "should create a new thread_tag_relationship with the new thread" do
          expect { click_button('Create thread') }.to change(ThreadTagRelationship, :count).by(1)
        end

        it "should create a new message with the new thread" do
          expect { click_button('Create thread') }.to change(Message, :count).by(1)
        end

        it "should create 2 nodes with the new thread" do
          expect { click_button('Create thread') }.to change(Treenode, :count).by(2)
        end
        
        describe "show page should be filled" do
           before { click_button 'Create thread' }
           it { should have_content('my title') }
        end
        
      end
    end

    describe "as a visitor" do
      before { get new_threadhead_path }
      specify { expect(response.body).not_to match(full_title('New thread')) }
      specify { response.should redirect_to(signin_path) }
    end
  end

end
