class MessagesController < ApplicationController

   before_action :signed_in_user, only: [:create, :destroy]
   before_action :admin_user, only: [:destroy]

  def create
    @message = Message.create_with_friends(message_params[:title],
                                           message_params[:text],
                                           current_user,
                                           message_params[:parent_node_id])
    unless @message.nil?
      Path.create(user: current_user,
                  threadhead_id: message_params[:threadhead_id],
                  treenode: @message.treenode)

      flash[:success] = "Answer sent"
      redirect_to threadhead_path(message_params[:threadhead_id])

    else
      flash[:error] = "Title and content of your message can't be blank"
      redirect_to threadhead_path(message_params[:threadhead_id])
    end
  end

  def destroy
    
  end

  private

    def message_params
      params.require(:message).permit(:title, :text, :threadhead_id, :parent_node_id)
    end
end
