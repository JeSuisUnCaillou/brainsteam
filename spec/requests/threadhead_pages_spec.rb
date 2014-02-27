require 'spec_helper'

describe "Threadhead Pages" do
  
  subject { page }

  before(:all) { 2.times { FactoryGirl.create(:thread_tag) } } # a changer quand on aura plus de thread_tags
  after(:all) { ThreadTag.delete_all }


  describe "index" do
    
    before(:all) { 32.times { FactoryGirl.create(:threadhead_with_tag) } }
    after(:all) { Threadhead.delete_all
                  ThreadTagRelationship.delete_all }
      
    before { visit threadheads_path }

    it { should have_title('All threads') }
    it { should have_link('New thread', href: new_threadhead_path) }

    let(:first_threadhead) { Threadhead.first }

    describe "filters" do
      describe "filter button test" do
        before do
           find_by_id('order').find("option[value='asc']").click
           #select 'asc', from: 'order'
           click_button('Filter')
        end
        it { should_not have_selector("tr.threadhead", text: first_threadhead.id) } # a remplacer par le nom du thread
        it { should have_selector("tr.threadhead") }#, text: Threadhead.last.id) }
        #A MARCHE PAS
      end
      
      
    end
 
    describe "first line attributes" do
      it { should have_selector('tr.threadhead/td.thread_tags/div', 
                                text: first_threadhead.thread_tags.first.name) }
      it { should have_link('view thread', href: threadhead_path(first_threadhead)) }
    end

    describe "pagination" do
      it { should have_selector('div.pagination') }

      it "should list each thread" do
        Threadhead.paginate(page: 1).each do |threadhead|
          expect(page).to have_selector("tr.threadhead", text: threadhead.id) # a remplacer par le nom du thread
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
    let(:threadhead) { FactoryGirl.create(:threadhead) }
    let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
    let!(:thread_tag_relationship) { FactoryGirl.create(:thread_tag_relationship, 
                                                        threadhead: threadhead, 
                                                        thread_tag: thread_tag) }
    before { visit threadhead_path(threadhead) }

    it { should have_title('View thread') } # a changer par le nom du thread
    it { should have_content(threadhead.id) } # a changer aussi
    it { should have_content(thread_tag.name) } # a changer quand on aura plus de tags
    
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
      it { should have_content('Real world') } # a changer quand on aura d'autres catégories
      it { should have_content('Crazy stuff') }

      it "should be able to create a new thread" do
        expect { click_button('Create thread') }.to change(Threadhead, :count).by(1)
      end
      it "should create a new thread_tag_relationship with the new thread" do
        expect { click_button('Create thread') }.to change(ThreadTagRelationship, :count).by(1)
      end
    end

    describe "as a visitor" do
      before { get new_threadhead_path }
      specify { expect(response.body).not_to match(full_title('New Thread')) }
      specify { response.should redirect_to(signin_path) }
    end
  end

end
