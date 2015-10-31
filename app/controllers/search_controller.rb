class SearchController < ApplicationController

  def index
    @cat = params[:cat]
  	@query = params[:search]
	
	

    if(params[:search].nil?)
		@users = User.paginate :page => params[:page]
		@jobs = Job.paginate :page => params[:page]
	else
		@users = User.search(params[:search], params[:page])
		@jobs = Job.search(params[:search], params[:page])
	end
	
	@categories = []
	@categorycount = []
	@categories = Category.all
	@categories.each{|x| @categorycount.push(0) }
	if(not @cat.nil?)
		@jobs = @jobs.where('category_id = ?',@cat)
	end
	
	@jobs.each do |job|
		if(not job.category_id.nil?)
			@categorycount[@categories.index(Category.where('id = ?',job.category_id).first)] += 1; 
		end
	end
    respond_to do |format|
      format.html # index.html.erb
    end
  end

end
