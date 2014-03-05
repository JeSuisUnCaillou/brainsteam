class ThreadTagRelationship < ActiveRecord::Base
  belongs_to :threadhead
  belongs_to :thread_tag

  validates :threadhead_id, presence: true
  validates :thread_tag_id, presence: true
  validate :thread_tag_id_exists
  validate :threadhead_id_exists

  private
    def thread_tag_id_exists
      errors.add(:thread_tag_id, "is invalid") unless ThreadTag.exists?(self.thread_tag_id)
    end

    def threadhead_id_exists
      errors.add(:threadhead_id, "is invalid") unless Threadhead.exists?(self.threadhead_id)
    end
end
