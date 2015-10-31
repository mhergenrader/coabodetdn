module ApplicationHelper

	def get_question_text_from_id(question_id)
		question = Question.select('text').where('id = ?',question_id).first
		if question.nil?
			'ERROR: cannot find question with id ' + question_id.to_s
		else
			question.text
		end
	end

	def get_choices_list_for_question(question_id) # could also link this to QuestionController via class method
		question_choice_ids = Inclusion.where('question_id = ?',question_id).order('updated_at ASC') # NOTE: must preserve order this way
  		if question_choice_ids.nil? or question_choice_ids.empty?
  			return []
  		end
  		
  		current_choice_ids = question_choice_ids.all.collect { |q| q.choice_id.to_i } # like in other cases, could replace with a join instead of repeated ones
  		current_options = []
  		current_choice_ids.each do |choice|
  			choice_row = Choice.where('id = ?',choice).first
  			if not choice_row.nil?
  				current_options << choice_row.value
  			else
  				current_options << 'nil'
  			end
  		end
		
		current_options #.join(', ')
	end
	
	def get_all_choices_for_question(question_id)
		get_choices_list_for_question(question_id).join(', ')
	end

	def get_current_user_profile_pic # more validation?
		profile = Profile.where('user_id = ?',current_user.id).first
		Image.where('profile_id = ? AND profile_picture = ?',profile.id,true).first unless profile.nil?
	end
	
	# return a better looking name for the the question type
	def get_pretty_question_type(question_short_type)
		case question_short_type
		when 'TEXT'
			"Text"
		when 'MC'
			"Multiple Choice"
		when 'MS'
			"Multiple Selection"
		else
			nil
		end
	end
	
	def get_dispute_owner(dispute)
		User.where('id = ?', dispute.owner_id).first
	end
	
	def get_dispute_offender(dispute)
		User.where('id = ?', dispute.offender_id).first
	end 
	
	# return the user's full name (first and last) given his/her id (the second param exists if you want the middle name to also be returned)
	def get_user_name_by_id(user_id, include_middle = false)
		if user_id.nil? 
			return 'ERROR'
		else
			user_name_fields = User.where('id = ?',user_id).first
			if user_name_fields.nil?
				return 'USER NOT FOUND'
			end
			
			if user_name_fields.middle_name.nil? or user_name_fields.middle_name.empty? # ignore include_middle if there is nothing
				"#{user_name_fields.first_name} #{user_name_fields.last_name}"
			else
				"#{user_name_fields.first_name} #{(include_middle ? user_name_fields.middle_name + ((user_name_fields.middle_name.length == 1)? '.' : '') : '')} #{user_name_fields.last_name}"
			end
		end
	end
	
	def get_user_name_by_profile_id(profile_id, include_middle = false)
		if profile_id.nil? 
			'ERROR'
		else
			profile = Profile.where('id = ?',profile_id).first
			if profile.nil?
				return 'PROFILE NOT FOUND'
			end
		
			user_name_fields = User.where('id = ?',profile.user_id).first
			if user_name_fields.nil?
				return 'USER NOT FOUND'
			end
			
			if user_name_fields.middle_name.nil? or user_name_fields.middle_name.empty? # ignore include_middle if there is nothing
				"#{user_name_fields.first_name} #{user_name_fields.last_name}"
			else
				"#{user_name_fields.first_name} #{(include_middle ? user_name_fields.middle_name + ((user_name_fields.middle_name.length == 1)? '.' : '') : '')} #{user_name_fields.last_name}"
			end
		end
	end
	
	
end

