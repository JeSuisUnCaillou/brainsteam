class ThreadTag < ActiveRecord::Base
  has_many :thread_tag_relationships
  has_many :threadheads, through: :thread_tag_relationships

end
