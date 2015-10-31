class WelcomeController < ApplicationController

  def index
	if user_signed_in?
		@current_profile = Profile.where('user_id = ?',current_user.id).first
		if not @current_profile.nil?
			@profile_image = Image.where('profile_id = ? AND profile_picture = ?',@current_profile.id,true).first	
		
			if @profile_image.nil? # find this user's profile image to load into the sidebar; if not found, get the stock photo
				@profile_image = Image.where('name = ?','no_profile_image').first # TODO: adjust image table so don't match on name
			end
		end
		
		@notifications = current_user.notifications.order("created_at DESC")
		

		
		respond_to do |format|
		  format.html { render "feed.html.erb", :layout => "feed" }
		end
		
		@notifications.each do |n| 
			n.read = true
			n.save
		end

	end	
  end
  
  def test
  
  
  end
  
  def about
  	
		respond_to do |format|
		  format.html { render "about.html.erb", :layout => "application" }
		end
		
  
  end
  
  def privacy
  
  	respond_to do |format|
		  format.html { render "privacy.html.erb", :layout => "application" }
		end
		
  end
 

end
