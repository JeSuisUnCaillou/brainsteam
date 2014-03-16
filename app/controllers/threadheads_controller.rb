class ThreadheadsController < ApplicationController

  before_action :signed_in_user, only: [:new, :create, :destroy]
  before_action :admin_user, only: [:destroy]

  def index
    order =  params.has_key?(:order) ? params[:order].to_sym : :desc
    id_table = []
    thread_tag_ids = ThreadTag.select(:id)
    if params.has_key?(:thread_tag) 
      for i in thread_tag_ids do
        id_table.push(i) if params[:thread_tag].has_key?(i.id.to_s)
      end
    else 
      id_table = thread_tag_ids
    end
 
    @threadheads = Threadhead.joins(:thread_tags) 
                             .where(thread_tags: {id: id_table})
                             .reorder(created_at: order) #a changer par un genre de :modified_at
                             .paginate(page: params[:page])

    @thread_tags = ThreadTag.all
  end

  def show

    @threadhead = Threadhead.find(params[:id])
    @new_message = Message.new
    paths = @threadhead.paths_by_user(current_user) # optimisable
   
    if signed_in? && paths.empty? #si le user n'est jamais venu sur ce thread
      path_1 = Path.create(user: current_user,
                  threadhead: @threadhead,
                  treenode: @threadhead.treenode) 
      path_2 = Path.create(user: current_user,
                  threadhead: @threadhead,
                  treenode: @threadhead.first_message.treenode)
    end

    ## Récupération et réorganisation des treenodes ##
   
    treenodes_temp = Treenode.joins(:paths)
                         .where(paths: {threadhead_id: @threadhead.id,
                                        user_id: current_user})
    @treenodes = []
    temp_node = treenodes_temp.where(obj_type: Threadhead.to_s).first
    @treenodes.push temp_node

    until treenodes_temp.where(parent_node_id: temp_node.id).empty? do
      ## on ne choisit qu'une réponse à la fois pour l'instant ##
      temp_node = treenodes_temp.where(parent_node_id: temp_node.id).first
      @treenodes.push temp_node
    end
 
    flash[:notice] = "Hey, buddy ! If you're not logged in,
                     I don't know what to do unless show
                     you the first message" unless signed_in?    
  end

  def new
    @threadhead = Threadhead.new
    @thread_tags = ThreadTag.all
  end

  def create
    @threadhead = Threadhead.create_with_friends(threadhead_params[:private],
                                                 threadhead_params[:message],
                                                 threadhead_params[:thread_tag_id],
                                                 current_user)
    if @threadhead.nil?
      flash[:error] = "Title and content of your message can't be blank"
      redirect_to new_threadhead_path
    else
      redirect_to threadhead_path(@threadhead)
    end
  end 

  def destroy
    threadhead = Threadhead.find(params[:id])
    treenode = Treenode.find(threadhead.treenode)
    #threadhead.destroy est fait par treenode.destroy, qui détruit aussi ses fils
    treenode.destroy
    flash[:success] = "Thread destroyed."
    redirect_to threadheads_path
  end 

  private

    def threadhead_params # a modifier après la v0.0
      params.require(:threadhead).permit(:private, 
                                         :thread_tag_id, 
                                         message: [:title, :text])
    end
    
end
