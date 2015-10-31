class ImagesController < ApplicationController

  # TODO with this method: render as thumbnails
  # view all images that a current profile has
  # GET /profiles/:profile_id/images
  def index
  	if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
  		respond_to do |format|
  			format.html { redirect_to root_url }
  		end
  		return
  	end
  	
  	@user_profile = Profile.where('id = ?',params[:profile_id]).first # verify the profile id
  	if @user_profile.nil? # TODO: could add privacy settings with regards to who can actually see these
  		respond_to do |format|
  			format.html { redirect_to root_url }
  		end
  		return
  	end
  	
  	@first_name = User.where('id = ?',@user_profile.user_id).first.first_name # just to add a more personal touch
  	
  	@view_edit_links = (@user_profile.user_id.to_i == current_user.id.to_i) # add some special functionality if user is one viewing his/her own pics  	
  	@all_images = Image.where('profile_id = ?',@user_profile.id)  	
  end


  # present form to upload a new picture
  # GET /profiles/:profile_id/images/:new
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
  	
  	#@has_no_images = (Image.where('profile_id = ?',@user_profile.id).count == 0)
  	@has_profile_image = !(Image.where('profile_id = ? AND profile_picture = ?',@user_profile.id,true).first.nil?)
  	
	@image = Image.new(:profile_id => @user_profile.id) # create for use with the form
  end


  # upload the new picture to the database via CarrierWave
  # POST /profiles/:profile_id/images
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
  	  	
  	@existing_profile_image = Image.where('profile_id = ? AND profile_picture = ?',@user_profile.id,true).first
  	if params[:image][:profile_picture].to_i == 1 and not @existing_profile_image.nil? # already have a specified profile image? if so, unmark it
  		@existing_profile_image = Image.update(@existing_profile_image.id, :profile_picture => false)
  	end
  	  	
  	@image = Image.new(:profile_id => @user_profile.id, :name => params[:image][:name], :image => params[:image][:image], :profile_picture => params[:image][:profile_picture], :image_description => params[:image][:image_description]) 	
  	
	begin
		@image.save!
	rescue ActiveRecord::RecordInvalid
		render :action => :new # return to the new form so that users can upload again (try to, anyway) (used to be render)
		return
	end	
	redirect_to profile_path(@user_profile.id)
	
	#if @image.save!
  	#  redirect_to profile_path(@user_profile.id)
    #else
    #  redirect_to :action => :new # return to the new form so that users can upload again (try to, anyway) (used to be render)
    #end    
  end
	
  
  # presents form with which user can edit all metadata
  # GET /profiles/:profile_id/images/:id/edit
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
  	
    @image = Image.where('id = ? AND profile_id = ?',params[:id],@user_profile.id).first
    if @image.nil?
    	redirect_to :action => :new # if there actually isn't any image to edit, must redirect them to make a new one, as it is not recognized
    end
  end


  # shows one individual picture
  # GET /profiles/:profile_id/images/:id
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
  	
  	@image = Image.where('id = ? AND profile_id = ?',params[:id],@user_profile.id).first # must check for nil!  	
  	if @image.nil?
    	redirect_to :action => :index # if there actually isn't any image to edit, must redirect them to all images to see if they can spot it
    end
  end


  # called by edit to update all metadata for a photo
  # PUT /profiles/:profile_id/images/:id
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
  	  		
  	image = Image.where('id = ? AND profile_id = ?',params[:id],user_profile.id).first
  	if not image.nil?
  		# must do the existing profile check here because must know the image to compare with first (in new, didn't have anything to compare with)
	  	@existing_profile_image = Image.where('profile_id = ? AND profile_picture = ?',user_profile.id,true).first
	  	if params[:image][:profile_picture].to_i == 1 and not @existing_profile_image.nil? and @existing_profile_image.id.to_i != image.id.to_i # already have a specified profile image? if so, unmark it
	  		@existing_profile_image = Image.update(@existing_profile_image.id, :profile_picture => false)
	  	end
  		
  		new_name = (params[:image][:name].to_s.empty? ? '[untitled]' : params[:image][:name].to_s)
  		current_image = Image.update(image.id, :name => new_name, :profile_picture => params[:image][:profile_picture], :image_description => params[:image][:image_description])  	
  		redirect_to :action => :index
  	else # still not a valid image (logged in user trying to modify an image that doesn't exist for them)
  		respond_to do |format|
  			format.html { redirect_to root_url }
  		end
  		return
  	end
  end
  
  
  # removes a specified photo for a profile
  # DELETE /profiles/:profile_id/images/:id
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
  	
  	image = Image.where('id = ? AND profile_id = ?',params[:id],@user_profile.id).first
  	if image.nil?
  		respond_to do |format|
  			format.html { redirect_to root_url } # could not destroy image (does not exist)
  		end
  		return
  	end
  	
  	image.destroy # image is removed from the database and from the filesystem with this command (includes all versions)
  	redirect_to :action => :index
  end  
end
