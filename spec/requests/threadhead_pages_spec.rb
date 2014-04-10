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

      describe "Last update order" do
        before do
           select 'Last update', from: 'order'
           click_button('Filter')
        end
        it { should have_selector("tr.threadhead",
                                  text: Threadhead.first.title) }
        it { should_not have_selector("tr.threadhead",
                                      text: Threadhead.last.title) }
      end

      describe "Views order" do
        before do
          select 'Views', from: 'order'
          click_button 'Filter'
        end
        it { should have_selector("tr.threadhead",
                                  text: Threadhead.sort_by_views.first.title) }
        it { should_not have_selector("tr.threadhead",
                                      text: Threadhead.sort_by_views.last.title) } 
      end
     

      describe "Answers order" do
        before do
          select 'Answers', from: 'order'
          click_button 'Filter'
        end
        it { should have_selector("tr.threadhead",
                                  text: Threadhead.sort_by_answers.first.title) }
        it { should_not have_selector("tr.threadhead",
                                      text: Threadhead.sort_by_answers.last.title) } 
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
      it { should have_link(first_threadhead.title, href: threadhead_path(first_threadhead)) }
      it { should have_selector('tr.threadhead', text: first_threadhead.first_message.title) }
      it { should have_selector('tr.threadhead', text: first_threadhead.user.name) }
      it { should have_selector("div#readers_count_#{first_threadhead.id}",
                                text: first_threadhead.treenode.paths.count) }
      it { should have_selector("div#answers_count_#{first_threadhead.id}",
                                text: first_threadhead.answers_count) }

      describe "new messages indicator" do
        it { should_not have_selector('div.new_answers_count') }
        
        describe "after visiting a thread and going back" do
          let!(:user) { FactoryGirl.create(:user) }
          before do
            sign_in user
            visit threadhead_path(first_threadhead)
            visit threadheads_path
          end
          it {should_not have_selector('div.new_answers_count', text: "0") }
        end

      end
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
          before { delete threadhead_path(first_threadhead) }
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
          before { delete threadhead_path(first_threadhead) }
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
          expect { click_link('delete', match: :first) }.to change(Threadhead, :count).by(-1)
        end

        let(:n) { first_threadhead.treenode.nodes_count }
        it "deleting a thread should actually delete all its treenodes" do
          expect { click_link('delete', match: :first) }.to change(Treenode, :count).by(-n)
        end

        it "deleting a thread should delete its first message" do
          expect { click_link('delete', match: :first) }.to change(Message, :count).by(-1)
        end

      end
    end
  end
  
  describe "thread show page" do
    let!(:thread_tag) { ThreadTag.first }
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user2) { FactoryGirl.create(:user) }
    let!(:threadhead) { FactoryGirl.create(:threadhead_and_friends) }
    let!(:answer) { FactoryGirl.create(:message, user: user) }
    let!(:m_node) { FactoryGirl.create(:treenode, obj: answer,
                                       parent_node: threadhead.first_message.treenode) }
    let!(:answer2) { FactoryGirl.create(:message, user: user) }
    let!(:m_node2) { FactoryGirl.create(:treenode, obj: answer2,
                                       parent_node: threadhead.first_message.treenode) }
    let!(:answer12) { FactoryGirl.create(:message, user: user) }
    let!(:m_node12) { FactoryGirl.create(:treenode, obj: answer12,
                                       parent_node: m_node) }

    before do
      sign_in user
      visit threadhead_path(threadhead)
    end 

    it { should have_title(threadhead.title) }
    it { should have_content(thread_tag.name) } # a changer quand on aura plus de tags
    it { should have_content(threadhead.title) }
    it { should have_content(threadhead.text) }
    it { should have_content(threadhead.user.name) }
    it { should have_selector("div#readers_count_#{threadhead.first_message.id}",
                              text: threadhead.first_message.treenode.paths.count) }
    it { should have_selector("div#answers_count_#{threadhead.first_message.id}",
                              text: threadhead.first_message.treenode.children_nodes.count) }

    it { should have_selector("div#new_answers_count_#{threadhead.first_message.id}",
                              text: "2") }

    describe "first answers" do
      it { should have_button(answer.title) }
      it { should have_button(answer2.title) }
      
      it "select an answer should add a path" do
        expect { click_button(answer.title) }.to change(Path, :count).by(1)
      end
     
      describe "after selecting an answer, it should be displayed" do
        before { click_button(answer.title) }
        let(:user_path) { Path.find_by(threadhead_id: threadhead.id,
                                       treenode_id: answer.treenode.id,
                                       user_id: user.id) }

        it { should have_content(answer.text) }

        # the first message's new_answer_count should have changed
        it { should have_selector("div#new_answers_count_#{threadhead.first_message.id}",
                              text: "1") }
        
        it "clicking on the close box should delete a path" do
          expect { click_link('x') }.to change(Path, :count).by(-1)
        end

        describe "submitting a DELETE request to the Path#destroy action" do
          let!(:reader) { FactoryGirl.create(:user) }
          before do
            sign_in reader, no_capybara: true
            visit threadhead_path(threadhead)
          end

          it "shouldn't delete the path" do
            expect { delete path_path(user_path) }.not_to change(Path, :count)
          end
        end

        describe "after closing an answer, it shouldn't be displayed" do
          before { click_link('x') }
          it { should_not have_content(answer.text) }
        end
       
        describe "after selecting another answer, it should be displayed" do
           before { click_button(answer12.title) }
           it { should have_content(answer12.text) }
           
           it "clicking on the first close box should delete all sub-paths" do
             expect { click_link('x', match: :first) }.to change(Path, :count).by(-2)
           end
        end

      end
      
    end


    describe "adding an answer" do

      describe "as a visitor" do
        #TODO POST REQUEST à faire
      end

      describe "as a logged_in user" do
        let!(:reader) { FactoryGirl.create(:user) }
        before do
          click_link 'Sign out'
          sign_in reader
          visit threadhead_path(threadhead)
        end

        describe "with valid informations" do
  
          before do
            fill_in :message_title, with: 'mon titre'
            fill_in :message_text, with: 'mon texte'
          end

          it "should create a message" do
            expect { click_button('Send') }.to change(Message, :count).by(1)
          end

          it "should create a treenode with the message" do
            expect { click_button('Send') }.to change(Treenode, :count).by(1)
          end
 
          it "should create a path with the message" do
            expect { click_button('Send') }.to change(Path, :count).by(1)
          end

          describe "then logged as another viewer" do
            let!(:viewer) { FactoryGirl.create(:user) }

            before do
              click_link 'Sign out'
              visit threadheads_path
              sign_in viewer
            end

            it { should_not have_selector('div.new_answers_count') }

            describe "visiting a thread" do
              before { visit threadhead_path(threadhead) }
             
              it { should have_selector('div.new_answers_count', text: "2") }

              describe "then coming back to index" do
                before { visit threadheads_path }
                it { should have_selector('div.new_answers_count', text: "2") }
              end
            end

          end

        end

        describe "with invalid informations" do
          it "shouldn't create a message" do
            expect { click_button('Send') }.not_to change(Message, :count)
          end
        end
    
      end

    end


    describe "edit a message" do

      describe "as the creator of the message" do
        before do
          fill_in :message_title, match: :first, with: 'edited title'
          fill_in :message_text, match: :first, with: 'edited text'
        end 
       
        it { should have_selector("input[type=submit][value='Edit']") }
        
        describe "should be able to edit the message" do
          before do
            page.find("#submit_edit").click
          end

          it { should have_content('edited title') }
          it { should have_content('edited text') }

        end 
      end

      describe "as another user" do
        let!(:reader) { FactoryGirl.create(:user) }
        before do
          click_link 'Sign out'
          sign_in reader 
          visit threadhead_path(threadhead)
        end

        it { should_not have_selector("input[type=submit][value='Edit']") }

        describe "submitting to the update action" do
          before { patch message_path(threadhead.first_message) }
          specify { expect(response).to redirect_to(root_path) }
        end

      end

      describe "as a visitor" do
        before do
          click_link 'Sign out'
          visit threadhead_path(threadhead)
        end
        
        it { should_not have_selector("input[type=submit][value='Edit']") }

        describe "submitting to the update action" do
          before { patch message_path(threadhead.first_message) }
          specify { expect(response).to redirect_to(root_path) }
        end
      end
      
    end


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
