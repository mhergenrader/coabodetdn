class ResumesController < ApplicationController
	
	# TODO: should a link to all of my profiles be in my profile as well as the sidebar?
	
	# GET /profiles/:profile_id/resumes - NOT SURE IF WILL USE THIS YET
	def index
	end
	
	
	# retrieve form to upload a new resume for this profile
	# GET /profiles/:profile_id/resumes/new
	def new
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	  	
	  	@user_profile = Profile.where('id = ?',params[:profile_id]).first
	  	if @user_profile.nil? or @user_profile.user_id.to_i != current_user.id.to_i # if the current profile id does not exist, then cannot proceed; if not our profile, cannot proceed: not authorized
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  		  	
		@resume = Resume.new(:profile_id => @user_profile.id) # create for use with the form
	end
	
	
	# upload this resume
	# POST /profiles/:profile_id/resumes
	def create
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	
	  	@user_profile = Profile.where('id = ?',params[:profile_id]).first
	  	if @user_profile.nil? or @user_profile.user_id.to_i != current_user.id.to_i # if the current profile id does not exist, then cannot proceed; if not our profile, cannot proceed: not authorized
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end # TODO: more verification of parameters?
	  		  	  	
	  	@resume = Resume.new(:profile_id => @user_profile.id, :name => params[:resume][:name], :resume => params[:resume][:resume], :resume_description => params[:resume][:resume_description])
	  	
		begin
			@resume.save!
		rescue ActiveRecord::RecordInvalid
			render :action => :new # return to the new form so that users can upload again (try to, anyway) (used to be render)
			return
		end	
		redirect_to profile_path(@user_profile.id)
		
		
		#if @resume.save!
	  	#  redirect_to profile_path(@user_profile.id)
	    #else
	    #  redirect_to :action => :new # return to the new form so that users can upload again (try to, anyway) (used to be render)
	    #end
	end
	
	
	# TODO: as a user, can I edit a resume itself? (interactive resume builder perhaps as an alternative to flat pdf's? - probably want a separate action for that, like 'resume_builder', which will always put (so can use for creating or editing)
	# GET /profiles/:profile_id/resumes/:id/edit
	def edit
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	
	  	@user_profile = Profile.where('id = ?',params[:profile_id]).first
	  	if @user_profile.nil? or @user_profile.user_id.to_i != current_user.id.to_i # if the current profile id does not exist, then cannot proceed; if not our profile, cannot proceed: not authorized
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	
	    @resume = Resume.where('id = ? AND profile_id = ?',params[:id],@user_profile.id).first
	    if @resume.nil?
	    	redirect_to :action => :new # if there actually isn't any image to edit, must redirect them to make a new one, as it is not recognized
	    end
	end
	
	
	# show the current resume
	# GET /profiles/:profile_id/resumes/:id
	def show
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	
	  	@user_profile = Profile.where('id = ?',params[:profile_id]).first
	  	if @user_profile.nil?  # if the current profile id does not exist, then cannot proceed; if not our profile, TODO: privacy settings
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	
	  	@resume = Resume.where('id = ? AND profile_id = ?',params[:id],@user_profile.id).first # must check for nil!  	
	  	if @resume.nil?
	    	redirect_to profile_path(@user_profile.id) # for now, just go back the profile (eventually, if use index, can go back there like images does)
	    end
	end
	
	
	# PUT /profiles/:profile_id/resumes/:id
	def update
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end  	
	  	
	  	user_profile = Profile.where('id = ?',params[:profile_id]).first
	  	if user_profile.nil? or user_profile.user_id.to_i != current_user.id.to_i # if the current profile id does not exist, then cannot proceed; if not our profile, cannot proceed: not authorized
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	  		
	  	resume = Resume.where('id = ? AND profile_id = ?',params[:id],user_profile.id).first
	  	if not resume.nil?	  		
	  		new_name = (params[:resume][:name].to_s.empty? ? '[untitled]' : params[:resume][:name].to_s)
	  		current_image = Resume.update(resume.id, :name => new_name, :resume_description => params[:resume][:resume_description])  	
	  		redirect_to profile_path(@user_profile.id) # :action => :index - for now, just go back to the profile
	  	else # still not a valid image (logged in user trying to modify an resume that doesn't exist for them)
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	end
	
	
	# DELETE /profiles/:profile_id/resumes/:id
	def destroy
		# TODO: do I need more security on this?
	  	if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end  	
	  	
	  	@user_profile = Profile.where('id = ?',params[:profile_id]).first
	  	if @user_profile.nil? or @user_profile.user_id.to_i != current_user.id.to_i # if the current profile id does not exist, then cannot proceed; if not our profile, cannot proceed: not authorized
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
	  	
	  	resume = Resume.where('id = ? AND profile_id = ?',params[:id],@user_profile.id).first
	  	if resume.nil?
	  		respond_to do |format|
	  			format.html { redirect_to root_url } # could not destroy resume (does not exist)
	  		end
	  		return
	  	end
	  	
	  	resume.destroy # image is removed from the database and from the filesystem with this command
	  	redirect_to profile_path(@user_profile.id) #:action => :index - for now
	end	
end
