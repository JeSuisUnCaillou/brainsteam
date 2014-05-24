require 'spec_helper'

  ### TOUT A REFAIRE ###

describe ThreadheadBuilder do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:thread_tag) { FactoryGirl.create(:thread_tag) }
  before do
    @threadhead_builder = ThreadheadBuilder.new(privat: false,
                                                text: "texte",
                                                title: "title",
                                                thread_tag_id: thread_tag.id,
                                                user: user)
  end

  subject{ @threadhead_builder }

  it { should_not be_valid }
  it { should respond_to(:privat) }
  it { should respond_to(:title) }
  it { should respond_to(:text) }
  it { should respond_to(:thread_tag_id) }
  it { should respond_to(:user) }

  it { should respond_to(:threadhead) }
  it { should respond_to(:thread_node) }
  it { should respond_to(:message) }
  it { should respond_to(:message_node) }


  describe "saving" do

    describe "with proper informations" do
      before { @threadhead_builder.save }

      its(:threadhead) { should be_valid }
      its(:thread_node) { should be_valid }
      its(:message) { should be_valid }
      its(:message_node) { should be_valid }
    end

    describe "with invalid title" do
      before do
        @threadhead_builder.title = ""
        @threadhead_builder.save
      end
      its(:message) { should_not be_valid }
      it { should_not be_valid }
    end

  end


end
