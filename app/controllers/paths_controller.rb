class PathsController < ApplicationController

  before_action :signed_in_user, only: [:create, :destroy]

  def create
    @path = Path.create_or_reactivate(current_user.id,
                                   path_params[:threadhead_id],
                                   path_params[:treenode_id])
    unless @path.nil?
      redirect_to threadhead_path(path_params[:threadhead_id])
    else 
      flash[:error] = "You already have selected this answer"
      redirect_to threadhead_path(path_params[:threadhead_id])
    end
  end

  def destroy
    path = Path.find(params[:id])

    if current_user?(path.user)

      unless path.treenode.has_threadhead_parent? || path.treenode.obj_type ==Threadhead.to_s
        path.desactivate_with_children_paths
      else
        flash[:error] = "You can't unread the first message of a thread, neither a thread"
      end

    else
      flash[:error] = "Don't even try it, dude."
    end

    redirect_to(threadhead_path(path.threadhead_id))
  end

  private

    def path_params
      params.require(:path).permit(:threadhead_id, :treenode_id)
    end
end
