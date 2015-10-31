module UsersHelper
	
	def get_profile_pic(profile_id)
		Image.where('profile_id = ? AND profile_picture = ?',profile_id,true).first
	end
	
end
