class ThreadTagRelationship < ActiveRecord::Base
  belongs_to :threadhead
  belongs_to :thread_tag

  validates :threadhead_id, presence: true
  validates :thread_tag_id, presence: true
end
