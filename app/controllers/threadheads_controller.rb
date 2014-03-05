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
    @thread_tags = @threadhead.thread_tags
  end

  def new
    @threadhead = Threadhead.new
    @thread_tags = ThreadTag.all
  end

  def create
    @threadhead = Threadhead.new(threadhead_params.slice(:private)) 
    if @threadhead.save
      @threadhead.link_tag!(threadhead_params[:thread_tag_id])
      redirect_to threadhead_path(@threadhead)
    end    
  end 

  def destroy
    threadhead = Threadhead.find(params[:id])
    threadhead.destroy
    flash[:success] = "Thread destroyed."
    redirect_to threadheads_path
  end 

  private

    def threadhead_params # a modifier après la v0.0
      params.require(:threadhead).permit(:private, :thread_tag_id)
    end
    
end