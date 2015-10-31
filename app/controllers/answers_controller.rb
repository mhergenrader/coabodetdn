class AnswersController < ApplicationController
	def index # TODO: add cancan
	end
	def new
	end
	def create
	end
	def show
	end
	
	# GET /profiles/:profile_id/answers/:id/edit <- interpret this as the question id
	def edit	
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
		
		@profile = Profile.where('id = ?',params[:profile_id]).first		
		if @profile.nil? or @profile.user_id.to_i != current_user.id.to_i   # if this user profile id does not exist or this is not the user's profile that is logged in, redirect to the home page
			redirect_to root_url
			return
		end
		
		@question = Question.where('id = ?',params[:id]).first # now that we know this user is accessing his/her own profile question to edit (that exists), check the question itself
		if @question.nil? # if trying to access a question that does not exist, raise an error message and render page
			@error_message = "ERROR: there is no existing question with id equal to #{params[:id]}" # TODO: make more user-friendly: add link to first existing question or to profile, if none exist
			redirect_to root_url
			return
		end
		
		# validation with respect to session and URL complete
				
		choice_ids = Inclusion.where('question_id = ?',@question.id) # TODO: could do a join
		if not choice_ids.nil?
			q_choice_ids = choice_ids.all.collect { |q| q.choice_id }
			@options = []
			q_choice_ids.each do |choice_id|
				@options << Choice.where('id = ?',choice_id).first.attributes['value']
			end
		else 
			@error_message = 'ERROR: no options'
		end		
		
		@answer = Answer.where('profile_id = ? AND question_id = ?',@profile.id,@question.id).first	  	
	  	if not @answer.nil?
	  		@user_response = @answer.response
	  		if @question.question_type == 'MS'
	  			@user_response = @user_response.split('##') #.map { |r| r =~ /^.+$/ ? nil : r }.compact
  			end
	  		
	  		#@user_comments = @answer.comments # not necessary to do this with comments - in fact the only real use of this block is to help the rails auto refill in edit is for multiple selection questions with multiple options picked
  		else
  			@answer = Answer.new
  		end
	  	 
  		# default ordering here is by id
	  	@all_question_names = Question.select('id,short_name').where('domain = ?',Question::PROFILE_DOMAIN).order('id ASC').all # finally, gather all surrounding questions for the second div element
	  	
	  	# need to modify this eventually with AJAX to get the ID for the links to create
  		# TODO: also need to make sure questions exist, so we don't get errors
  		@prev_questions = @all_question_names.find_all { |q| q.id.to_i < @question.id.to_i }  		
  		@prev_question = @prev_questions.empty? ? @all_question_names.last : @prev_questions.last  # fetch the previous question name and id 		
  		  		
  		@next_questions = @all_question_names.find_all { |q| q.id.to_i > @question.id.to_i }
  		@next_question = @next_questions.empty? ? @all_question_names.first : @next_questions.first  # fetch the next question name and id
	  		  	
	  	# this was just added (3/30) - TODO: can this be better optimized instead of having to do a query for every question?
	  	# could do a left join of questions and answers on question.id = answer.question_id... (left because there might not be answer, so incompleteq!)
	  	@all_question_names.each do |qn|
	  		answer = Answer.where("profile_id = ? AND question_id = ?",@profile.id,qn.id).first
	  		if answer.nil?
	  			qn[:class] = 'btn btn-danger'
  			elsif answer.response.empty? or answer.comments.empty? # if there is nothing to either the response or the comments, it should match the profile coloring
	  			qn[:class] = 'btn btn-warning'
  			else
	  			qn[:class] = 'btn btn-success'
  			end	  		
	  		#qn[:class] = (Answer.where("profile_id = ? AND question_id = ?",@profile.id,qn.id).first.nil? ? 'btn btn-danger' : 'btn btn-success') #incompleteq,completeq
  		end
  		
   		# this is another way to do it that will involve fewer queries (though does include a join)
  		# a minimal way to check if an answer exists for this particular question is to check the associated question id
  		#@all_question_names = Question.find(:all,:select => 'questions.id, questions.short_name, answers.profile_id, answers.question_id', :joins => 'LEFT OUTER JOIN answers ON answers.question_id = questions.id', :where => "answers.profile_id = #{@profile.id}")
		#@all_question_names = Question.select('questions.id, questions.short_name, answers.profile_id, answers.question_id').where('answers.profile_id = ?',@profile.id).joins('LEFT OUTER JOIN answers ON answers.question_id = questions.id')
		# TODO (not working quite the way I want)		
		
		#respond_to do |format| # no...
		#	format.html
		#	format.js { redirect_to 'http://google.com'}
		#end
	end
	
	
	# PUT /profiles/:profile_id/answers/:id <-- interpret this :id as the question id
	def update		
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		redirect_to root_url
	  		return
	  	end
		
		profile = Profile.select('id,user_id').where('id = ?',params[:profile_id]).first
		if profile.nil? or profile.user_id.to_i != current_user.id.to_i   # if profile does not exist or does not belong to current user, don't let them edit
			redirect_to root_url
			return
		end
		
		question = Question.select('id,question_type').where('id = ?',params[:id]).first # check the question itself
		if question.nil? # if trying to access a question that does not exist, redirect the user to the main page (TODO: figure out a better solution)
			redirect_to root_url
			return
		end
				
	  	user_response = _get_user_response(question,params[:answer]) # will return a string or nil, depending on whether an error occurred - works for all response types
	  	if user_response.nil? # experienced an error (empty string is not an error - this just indicates the question was blank for the particular type)
	  		redirect_to root_url
	  		return
	  	end
	  	
	  	user_comments = params[:answer][:comments]
	  	if user_comments.nil? # if user did not submit comments (normally should be empty string), transform to empty string
	  		user_comments = ''
	  	end	  	
	  	
	  	if user_response.empty? and user_comments.empty? # try to delete an existing question
		  	current_answer = Answer.select(:id).where('profile_id = ? AND question_id = ?',profile.id,question.id).first
		  	if not current_answer.nil?
		  		Answer.destroy(current_answer.id)
		  		@error = 'ok'
	  		#else
	  		#	@error = "could not destroy current record for user #{profile.id} and question #{question.id}"
  			end
  		else
  			# enforce idempotency here (put must be an idempotent action) by checking if an answer for the question already exists (for this user)		  			  	
		  	current_answer = Answer.select('id').where('profile_id = ? AND question_id = ?',profile.id,question.id).first
  			if current_answer.nil? # not found for this user, so can store a new one
		  	  	answer = Answer.new(:response => user_response, :comments => user_comments, :profile_id => profile.id, :question_id => question.id)
		  	  	if answer.save
		  			@error = 'ok'
		  		else
		  			@error = 'ERROR: failed to create new record'
		  		end
		 	else
		 		current_answer = Answer.update(current_answer.id.to_i, :response => user_response, :comments => user_comments)
		 		@error = 'ok'
		 		#current_answer.update_attributes(:response => user_response, :comments => user_comments)		 		
		  		#@save_status = "updated current record for user #{@profile.id} and question #{@question.id}, yielding answer id #{current_answer.id}"
		  	end
  		end
  		
  		if @error.nil?
  			@error = 'ok' # if no error was specified, then everything seems to be good
  		end
	  	
		respond_to do |format|
            format.json { render :json => {:saved => @error}.to_json }
        end		
	end
	
	# TODO: add logic for orphaned answers (if applicable), redirecting instead of debugging with own view
	# removes a user answer without the user having to clear all entries (response and comments)
	# this was added specifically because of multiple choice questions (can't be cleared), but apply to any
	# DELETE /profiles/:profile_id/answers/:id
	def destroy
		if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
	  	end
		
		@profile = Profile.where('id = ?',params[:profile_id]).first
		if @profile.nil? or @profile.user_id.to_i != current_user.id.to_i   # if profile does not exist or does not belong to current user, don't let them edit
			#redirect_to root_url
			#return
	  		@save_status = 'ERROR: invalid profile or profile that doesn\'t belong to you'
		end
		
		# user is now validated: he/she is logged in, and this profile belongs to him/her - now must check the answer itself - check the corresponding		
		# TODO: what to do about orphaned answers? cannot be deleted by a user! (would have to use the "StepQuestion" idea)
				
		@question = Question.where('id = ?',params[:id]).first # check the question itself
		if @question.nil? # if trying to access a question that does not exist, redirect the user to the main page (TODO: figure out a better solution)
			#redirect_to root_url
			#return
	  		@save_status = 'ERROR: corresponding question does not exist (the one passed in the URL)'
		end
		
		@current_answer = Answer.select(:id).where('profile_id = ? AND question_id = ?',@profile.id,@question.id).first
		if not @current_answer.nil? # found a match, so remove entry
	  		@current_answer.destroy
	  		@save_status = "destroyed current record for user #{@profile.id} and question #{@question.id}"
  		else
	  		@save_status = "could not destroy current record for user #{@profile.id} and question #{@question.id}" # not always a bad thing: just means it didn't exist in the first place (we are skipping); but if clearing, then this is a problem
  			#redirect_to 'http://google.com'
  			#return  		
  		end		
		
		#redirect_to { profile_path(@profile.id) } # just give control back to the profile
  		#return	
	end
	
	
 	private
  
  	# return the appropriate response if it exists; return nil if an error (bad question id or type); return '' if response doesn't exist
  	def _get_user_response(question,answer_params)
		case question.question_type
			when "TEXT"
		  		return answer_params[:response] # this could be empty string from form (so don't have to assign it explicitly) - don't need to check nil			
			when "MC"
		  		return (answer_params[:response].nil? ? '' : answer_params[:response]) # if nothing selected, first part of ternary operator will return nil - convert this to empty string
			when "MS"				
				@ms_values = answer_params[:response].map{ |i| i != '0' ? i : nil }.compact # first grab all multiple selection values, if any; remove any nils inside; done backwards like this so labels will tie to check box elements	
		  		return (@ms_values.empty? ? '' : @ms_values.join('##'))	  		
			else
		  		return nil # error occurred - question is not of designated type
		end
  	end
  	
  	
  	
  	
  	
end
