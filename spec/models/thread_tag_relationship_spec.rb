require 'spec_helper'

describe ThreadTagRelationship do
  let(:threadhead) { FactoryGirl.create(:threadhead) }
  let(:thread_tag) { FactoryGirl.create(:thread_tag) }
  let(:thread_tag_relationship) { threadhead.thread_tag_relationships.build(thread_tag_id: thread_tag.id) }


  subject { thread_tag_relationship }

  it { should be_valid }

  describe "association methods" do
    it { should respond_to(:thread_tag) }
    it { should respond_to(:threadhead) }
    its(:thread_tag) { should eq thread_tag }
    its(:threadhead) { should eq threadhead }
  end

  describe "when thread_tag_id is not present" do
    before { thread_tag_relationship.thread_tag_id = nil }
    it { should_not be_valid }
  end

  describe "when thread_tag_id doesn't exist" do
    before { thread_tag_relationship.thread_tag_id = -1 }
    it { should_not be_valid }
  end

  describe "when threadhead_id is not present" do
    before { thread_tag_relationship.threadhead_id = nil }
    it { should_not be_valid }
  end
 
  describe "when threadhead_id is doesn't exist" do
    before { thread_tag_relationship.threadhead_id = -1 }
    it { should_not be_valid }
  end
 
end
