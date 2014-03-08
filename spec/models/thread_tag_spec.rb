require 'spec_helper'

describe ThreadTag do

  before { @threadtag = ThreadTag.new(name: "Real world") }

  subject { @threadtag }

  it { should respond_to(:name) }
  it { should respond_to(:thread_tag_relationships) }
  it { should respond_to(:threadheads) }

  it { should be_valid }

  describe "when name is not present" do
    before { @threadtag.name = nil }
    it { should_not be_valid }
  end

  describe "when name is already taken" do
    before do
      tt = @threadtag.dup
      tt.save
    end
    it { should_not be_valid }
  end

end
