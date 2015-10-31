class JobApplicantsController < ApplicationController
	load_and_authorize_resource


  # GET /job_applicants
  # GET /job_applicants.json
  def index
    @job_applicants = JobApplicant.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @job_applicants }
    end
  end

  # GET /job_applicants/1
  # GET /job_applicants/1.json
  def show
    @job_applicant = JobApplicant.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job_applicant }
    end
  end

  # GET /job_applicants/new
  # GET /job_applicants/new.json
  def new
    @job_applicant = JobApplicant.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job_applicant }
    end
  end

  # GET /job_applicants/1/edit
  def edit
    @job_applicant = JobApplicant.find(params[:id])
  end

  # POST /job_applicants
  # POST /job_applicants.json
  def create
    @job_applicant = JobApplicant.new(params[:job_applicant])
	@job_applicant.applicant = current_user
	
      #when we create an applicant, set all the validates value
    @job_applicant.is_hired=false
    @job_applicant.is_paid = false
	
    respond_to do |format|
      if @job_applicant.save
		#this could be changed in the future!
		format.html { redirect_to @job_applicant.job, notice: 'You successfully applied for the job.' }
        format.json { render json: @job_applicant.job, status: :created, location: @job_applicant.job }
      else
        format.html { render action: "new" }
        format.json { render json: @job_applicant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /job_applicants/1
  # PUT /job_applicants/1.json
  def update
    @job_applicant = JobApplicant.find(params[:id])

    respond_to do |format|
      if @job_applicant.update_attributes(params[:job_applicant])
        format.html { redirect_to @job_applicant, notice: 'Job applicant was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @job_applicant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_applicants/1
  # DELETE /job_applicants/1.json
  def destroy
    @job_applicant = JobApplicant.find(params[:id])
    @job_applicant.destroy

    respond_to do |format|
      format.html { redirect_to job_applicants_url }
      format.json { head :ok }
    end
  end
end
