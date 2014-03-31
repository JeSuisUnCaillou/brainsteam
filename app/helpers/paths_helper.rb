module PathsHelper

  def path_of_current_user(treenode)
    signed_in? ? Path.find_by(treenode_id: treenode.id, user: current_user) : nil
  end

  def last_message_read(threadhead)
    if signed_in? 
      last_path = Path.where(threadhead_id: threadhead.id,
                            user_id: current_user.id).order('created_at DESC').first
      unless last_path.nil?
        return last_path.treenode.obj_id
      end
    end

    return nil
  end

end
