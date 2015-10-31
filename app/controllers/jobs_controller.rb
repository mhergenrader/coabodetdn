class JobsController < ApplicationController
  authorize_resource

  
   def index
	@jobs = Job.all 
	
	if current_user != nil
		@jobs = Job.all - current_user.jobs
	end
	
	respond_to do |format|
	  format.html { render :layout => "jobs" }# index.html.erb
	  format.xml { render xml: @jobs }
	  format.json { render json: @jobs }
	end
  end
  
  def alljobs
	@jobs = Job.all
  end
  
  # GET /jobs
  # GET /jobs.json
  def area
		@jobs = Job.search(params[:search], params[:page])
	respond_to do |format|
	  format.html { render :layout => "jobs_search_by_area" }# index.html.erb
	  format.xml { render xml: @jobs }
	  format.json { render json: @jobs }
	end
  end
  
   def posted
	if current_user != nil
		@jobs = current_user.jobs
	end
	respond_to do |format|
	  format.html { render :layout => "jobs" }# index.html.erb
	  format.xml { render xml: @jobs }
	  format.json { render json: @jobs }
	end
  end
  
   def applied
	if current_user != nil
		@applied_jobs = current_user.job_applications
	end
	respond_to do |format|
	  format.html { render :layout => "jobs" }# index.html.erb
	  format.xml { render xml: @jobs }
	  format.json { render json: @jobs }
	end
  end
  
  
  
  def accept
	@job_applicant = JobApplicant.find(params[:id])
    if @job_applicant.job.is_accepted == false
	   @job_applicant.is_hired = true;
       @job = @job_applicant.job
        
        if(@job.accept_counter == nil)
            @job.accept_counter = 0
            end
        
       @job.accept_counter +=1
       if @job.accept_counter == @job.num_of_workers
          @job.is_accepted = true
       end
       
	   respond_to do |format|
		if @job_applicant.save and @job.save
			format.html { redirect_to @job, notice: 'Job applicant successfully accepted.' }
		end
	   end
    else
        format.html { redirect_to @job, notice: 'Job has been taken.' }
    end
   
    
  end


 
  

  # GET /jobs/1
  # GET /jobs/1.json
  def show
	@job = Job.find(params[:id])
	@job_applicant = JobApplicant.new

	respond_to do |format|
	  format.html # show.html.erb
	  format.json { render json: @job }
	  format.xml { render xml: @job}
	end
  end
  
  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @job = Job.new
	@categories = Category.all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
	@categories = Category.all
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(params[:job])
    @job.user = current_user
    @job.is_accepted = false
    @job.accept_counter = 0
	@categories = Category.all
    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def update
   @job = Job.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :ok }
    end
  end
end
