class ThreadheadsController < ApplicationController

  before_action :signed_in_user, only: [:new, :create, :destroy]
  before_action :admin_user, only: [:destroy]

  def index
    store_location    

    id_table = []
    thread_tag_ids = ThreadTag.select(:id)
    if params.has_key?(:thread_tag) 
      for i in thread_tag_ids do
        id_table.push(i) if params[:thread_tag].has_key?(i.id.to_s)
      end
    else 
      id_table = thread_tag_ids
    end
 
    threadheads = Threadhead.joins(:thread_tags) 
                             .where(thread_tags: {id: id_table})

    order =  params.has_key?(:order) ? params[:order].to_sym : :last_message_date

    if order == :views
      threadheads = threadheads.sort_by_views
    elsif order == :answers
      threadheads = threadheads.sort_by_answers
    elsif order == :last_message_date
      #do nothing
    else
      #do nothing
    end
    
    @threadheads = threadheads.paginate(page: params[:page])

    @thread_tags = ThreadTag.all
  end


  def show
    store_location    

    @threadhead = Threadhead.find(params[:id])
    @new_message = Message.new
    @new_path = Path.new

    paths = @threadhead.paths.by_user(current_user)
   
    if signed_in? && paths.empty? #si le user n'est jamais venu sur ce thread
      path_1 = Path.create(user: current_user,
                  threadhead: @threadhead,
                  treenode: @threadhead.treenode) 
      path_2 = Path.create(user: current_user,
                  threadhead: @threadhead,
                  treenode: @threadhead.first_message.treenode)
    end

    ## Récupération des treenodes ## 
    @treenodes = @threadhead.treenodes_for_user(current_user)

    flash[:notice] = "Hey, buddy ! If you're not logged in,
                     I don't know what to do unless show
                     you the first message" unless signed_in?
  end


  def new
    @threadhead = Threadhead.new
    @threadhead_builder = ThreadheadBuilder.new
    @thread_tags = ThreadTag.all
  end

  def create
    @threadhead = Threadhead.create_with_friends(threadhead_params[:private],
                                                 threadhead_params[:message],
                                                 threadhead_params[:thread_tag_id],
                                                 current_user)
    if @threadhead.nil?
      message = Message.new(title: threadhead_params[:message][:title],
                            text: threadhead_params[:message][:text],
                            user: current_user,
                            threadhead: Threadhead.first)
      message.save # ce message sert juste à récupérer les erreurs de création
      message.destroy
      flash[:error] = message.errors.full_messages
      redirect_to new_threadhead_path
    else
      redirect_to threadhead_path(@threadhead)
    end
  end 

  def destroy
    threadhead = Threadhead.find(params[:id])
    treenode = Treenode.find(threadhead.treenode)
    #threadhead.destroy est fait par treenode.destroy, qui détruit tous ses objets et fils
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
