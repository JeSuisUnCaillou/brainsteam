module PathsHelper

  def new_answers_for_current_user(tn) #accepts an array of treenodes too
    
    # fetch viewed treenodes, even with desactivated paths
    tns_already_viewed = Treenode.where(parent_node_id: tn)
                                 .joins('INNER JOIN paths 
                                         ON paths.treenode_id = treenodes.id')
                                 .where(paths: {user_id: current_user.id})
    if tns_already_viewed.empty?
      tns = Treenode.where(parent_node_id: tn)
    else
      tns = Treenode.where(parent_node_id: tn)
                    .where('id NOT IN (?)', tns_already_viewed.map{ |t| t.id })
    end
    return tns
  end

  def path_of_current_user(treenode)
    signed_in? ? Path.find_by(treenode_id: treenode.id, user: current_user) : nil
  end

  def desactivated_path_of_current_user(treenode)
    signed_in? ? Path.desactivated.find_by(treenode_id: treenode.id,
                                           user: current_user) : nil
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
