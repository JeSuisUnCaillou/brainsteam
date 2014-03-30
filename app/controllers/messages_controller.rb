class MessagesController < ApplicationController

   before_action :signed_in_user, only: [:create, :destroy]
   before_action :admin_user, only: [:destroy]

  def create
    @message = Message.create_with_friends(message_params[:title],
                                           message_params[:text],
                                           current_user,
                                           message_params[:parent_node_id],
                                           message_params[:threadhead_id])
    if @message.valid?
      Path.create(user: current_user,
                  threadhead_id: message_params[:threadhead_id],
                  treenode: @message.treenode)

      flash[:success] = "Answer sent"
      redirect_to threadhead_path(message_params[:threadhead_id])

    else
      flash[:error] = @message.errors.full_messages
      redirect_to threadhead_path(message_params[:threadhead_id])
    end
  end

  def destroy
    
  end

  def update
    message = Message.find(params[:id])

    if current_user?(message.user)

      message.title = message_params[:title]
 
      if message.update_attributes(title: message_params[:title],
                                   text: message_params[:text])
        flash[:success] = "Message updated"
      else
        flash[:error] = message.errors.full_messages
      end  
      redirect_to(:back)

    else
      flash[:error] = "You are trying to edit someone else's message. I'll tell your mom"
      redirect_to root_path
    end
  end

  private

    def message_params
      params.require(:message).permit(:title, :text, :threadhead_id, :parent_node_id)
    end
end
