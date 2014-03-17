module PathsHelper

  def path_of_current_user(treenode)
    signed_in? ? Path.find_by(treenode_id: treenode.id, user: current_user) : nil
  end

end
