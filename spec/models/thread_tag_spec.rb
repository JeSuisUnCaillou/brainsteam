require 'spec_helper'

describe ThreadTag do

  before { @threadtag = ThreadTag.new(name: "Real world") }

  subject { @threadtag }

  it { should respond_to(:name) }
  it { should respond_to(:thread_tag_relationships) }
  it { should respond_to(:threadheads) }

  it { should be_valid }
end
