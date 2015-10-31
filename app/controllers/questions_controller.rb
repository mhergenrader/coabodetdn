class QuestionsController < ApplicationController
	#autocomplete :choice, :value, :full => true NOT NEEDED anymore for this in particular (but keep in case query time for choice becomes prohibitively expensive)
	load_and_authorize_resource
	
	# GET /admin/questions - shows all currently created questions
	def index	  	
		if Rails.configuration.database_configuration[Rails.env]['adapter'] == 'sqlite3'
	  		@questions = Question.select('questions.*, answers.question_id, COUNT(answers.question_id) as count').joins('LEFT OUTER JOIN answers ON answers.question_id = questions.id').group('questions.id')
		elsif Rails.configuration.database_configuration[Rails.env]['adapter'] == 'postgresql'
			@questions = Question.select('questions.*, COUNT(answers.question_id) as count').joins('LEFT OUTER JOIN answers ON answers.question_id = questions.id').group('questions.id, questions.short_name, questions.text, questions.question_type, questions.created_at, questions.updated_at, questions.created_by, questions.min_required, questions.max_acceptable, questions.updated_by, questions.domain')
		else
			@error_message = 'ERROR: database not recognized: ' + Rails.configuration.database_configuration[Rails.env]["adapter"]
		end
  	end
	
	
	# GET /admin/questions/new - get an HTML form for creating a new question
	def new
		all_questions = Question.select('short_name,text').all
		@question_names = "[#{all_questions.collect { |q| "\"#{q.short_name}\"" }.compact.join(',')}]"
		@question_texts = "[#{all_questions.collect { |q| "\"#{q.text}\"" }.compact.join(',')}]"
		
		@all_choices = "[#{Choice.select('value').order('value ASC').all.collect { |c| "\"#{c.value}\"" }.compact.join(',')}]" # construct list for typeahead
		@new_question = Question.new
	end
	
	
	# POST /admin/questions - creates a new question from new command - adds to question table
	def create  	
	  	# TODO: make sure that there are no duplicates for questions
	  	
	  	if params[:question].nil?
	  		@error_message = 'ERROR: no question parameter provided'
  		elsif params[:question][:short_name].nil? or params[:question][:short_name].empty?
  			@error_message = 'ERROR: no short name provided'
  		elsif params[:question][:text].nil? or params[:question][:text].empty?
  			@error_message = 'ERROR: no question text provided'
  		elsif params[:question][:question_type].nil? or params[:question][:question_type].empty?
  			@error_message = 'ERROR: no question type provided'
		elsif params[:question][:domain].nil? or params[:question][:domain].empty?
			@error_message = 'ERROR: no question domain provided'
		elsif not [Question::UNFILED_DOMAIN,Question::PROFILE_DOMAIN,Question::FEEDBACK_DOMAIN].include?(params[:question][:domain].downcase)
			@error_message = 'ERROR: invalid question domain provided'
  		elsif not ['Text','Multiple Choice','Multiple Selection'].include?(params[:question][:question_type])
  			@error_message = 'ERROR: invalid question type'
  		elsif params[:question][:question_type] != 'Text' and (params[:choices].nil? or params[:choices].empty?)
  			@error_message = 'ERROR: did not specify choices for a choice question'  			
  		else
		  	question_type = _condense_question_type(params[:question][:question_type])
  			# TODO: make sure that there are no duplicates
		  	  			
		  	if question_type.nil?
  				@error_message = 'ERROR: could not condense question type properly!'
  			else
			  	_create_new_question params[:question][:short_name], params[:question][:text], question_type, params[:question][:domain].downcase, current_user.id, params[:choices]
	  		end
  		end
  		if @error_message.nil? or @error_message.index('ERROR').nil? # if there is an error, stay on this page; else, allow user to continue
  			redirect_to :action => :index
  		end
	end
	
	# GET /admin/questions/:id - display all information about the current question
	def show
		_get_current_question_and_choices(params[:id])
	end
	
	
	# GET /admin/questions/:id/edit - display HTML form for user to edit questions
	def edit # TODO: do I need to actually order it?
		all_questions = Question.select('short_name,text').all
		@question_names = "[#{all_questions.collect { |q| "\"#{q.short_name}\"" }.compact.join(',')}]"
		@question_texts = "[#{all_questions.collect { |q| "\"#{q.text}\"" }.compact.join(',')}]"
		
		@all_choices = "[#{Choice.select('value').order('value ASC').all.collect { |c| "\"#{c.value}\"" }.compact.join(',')}]" # construct list for typeahead
		_get_current_question_and_choices(params[:id])
	end
	
	
	# PUT /admin/questions/:id - receives calls from edit - update all fields for existing or create if it doesn't exist
	def update  	
	  	# TODO: make sure that there are no duplicates for questions
	  	
	  	@param_list = params # for debugging in case of errors (see update.html.erb)
	  	
	  	#return
	  	if params[:id].nil?
	  		@error_message = 'ERROR: invalid question id'
	  	elsif params[:question].nil?
	  		@error_message = 'ERROR: no question parameter provided'
  		elsif params[:question][:short_name].nil? or params[:question][:short_name].empty?
  			@error_message = 'ERROR: no short name provided'
  		elsif params[:question][:text].nil? or params[:question][:text].empty?
  			@error_message = 'ERROR: no question text provided'
  		elsif params[:question][:question_type].nil? or params[:question][:question_type].empty?
  			@error_message = 'ERROR: no question type provided'
		elsif params[:question][:domain].nil? or params[:question][:domain].empty?
			@error_message = 'ERROR: no question domain provided'
		elsif not [Question::UNFILED_DOMAIN,Question::PROFILE_DOMAIN,Question::FEEDBACK_DOMAIN].include?(params[:question][:domain].downcase)
			@error_message = 'ERROR: invalid question domain provided'
  		elsif not ['Text','Multiple Choice','Multiple Selection'].include?(params[:question][:question_type])
  			@error_message = 'ERROR: invalid question type'
  		elsif params[:question][:question_type] != 'Text' and (params[:choices].nil? or params[:choices].empty?)
  			@error_message = 'ERROR: did not specify choices for a choice question'  			
  		else
		  	question_type = _condense_question_type(params[:question][:question_type]) # represents the desired new question type
  			# TODO: make sure that there are no duplicates
		  	
		  	if question_type.nil?
  				@error_message = 'ERROR: could not condense question type properly!'
  			else
  				# now can save the question, but first must check if it already exists - won't the question always exist?
  				current_question = Question.where('id = ?',params[:id]).first  				
			  	if current_question.nil? # not found, so will make and store a new one - rare occasion, but enforces idempotency		  		
			  		# this will create a new question, create any choices that don't already exist, and replace all Inclusions
			  	  	_create_new_question params[:question][:short_name], params[:question][:text], question_type, params[:question][:domain].downcase, current_user.id, params[:choices]		  		
		 		else # this question already exists - just update its information and update the choices database with any new choices; also replace all Inclusion links
			  		@previous_question_type = current_question.question_type
		 			@question = Question.update(current_question.id.to_i, :short_name => params[:question][:short_name], :text => params[:question][:text], :question_type => question_type, :updated_by => current_user.id, :domain => params[:question][:domain].downcase) # updated_at will be done automatically by Rails
			  		@error_message = '[INFO] Question updated in database!'
			  		
		  			# update possbilities:
		  			# text -> text: do nothing (just modify the question above)
		  			# text -> mc/ms (non-text): add all non-existing choices from params, add Inclusion records between choices and all params (no need to replace here; can't be any choices for a former text question)
					# mc/ms (non-text) -> text: delete all existing Inclusion records between choices and question
					# mc/ms (non-text) -> mc/ms (non-text): 
		  			
			  		if @previous_question_type == 'TEXT' and question_type != 'TEXT'
			  			_update_current_choices_and_inclusions(@question.id,params[:choices])
		  			elsif @previous_question_type != 'TEXT' and question_type == 'TEXT'
		  				# only delete the old inclusion ties (questions are, after all, decoupled from choices)
		  				#old_ties = Inclusion.where('question_id = ?',).all.collect { |i| i.choice_id.to_i }
		  				#Inclusion.destroy_all("question_id = #{current_question.id.to_i}")
		  				ActiveRecord::Base.connection.execute("DELETE FROM inclusions WHERE question_id = #{current_question.id.to_i}") # is there a better way?	
		  				
		  			elsif @previous_question_type != 'TEXT' and question_type != 'TEXT'
		  				# here, must delete old Inclusion ties before adding the new ones (which, in effect, replaces all ties)
		  				#Inclusion.destroy_all("question_id = #{current_question.id.to_i}")
		  				ActiveRecord::Base.connection.execute("DELETE FROM inclusions WHERE question_id = #{current_question.id.to_i}")
		  				_update_current_choices_and_inclusions(@question.id,params[:choices])
	  				end		  		
		  		end
	  		end
  		end
  		
  		if @error_message.index('ERROR').nil? # if there is an error, stay on this page; else, allow user to continue
  			redirect_to :action => :index
  		end
	end
	
	
	def destroy # TODO: should I destroy all answers associated with this question? will users be happy with that?		
	end	
	
	
	private
	
	# text transformation from the displayed question type to the database one
	def _condense_question_type(long_question_type)
		case long_question_type
		when 'Text'
			'TEXT'
		when 'Multiple Choice'
			'MC'			
		when 'Multiple Selection'
			'MS'			
		else
			nil
		end
	end
	
	# helper method that creates a new question, creates any new choices that the user specified, and updates the link relationships in inclusions
	def _create_new_question(short_name, text, question_type, domain, current_user_id, choices)
		@new_question = Question.new(:short_name => short_name, :text => text, :question_type => question_type, :created_by => current_user.id, :updated_by => current_user.id, :domain => domain)
	  	if @new_question.save
	  		@error_message = '[INFO] Question saved to database!'
  		else
  			@error_message = 'ERROR: could not save new question'
  		end
  		
  		if question_type != 'TEXT' # if this was a choice question, store the choices
  			_update_current_choices_and_inclusions(@new_question.id,choices)
		end
	end
	
	
	# add any new choices the user specified to the Choice table and add any new Choice-Question relationships to the Inclusion model
	def _update_current_choices_and_inclusions(question_id, choices)
		@choices = choices
		@choices.each do |choice|
			# check first if this option already exists to help prevent duplicate choices
			existing_choice = Choice.where('value = ?',choice).first				
			if existing_choice.nil? # if doesn't already exist, store it
				@new_choice = Choice.new(:value => choice)
				if @new_choice.save # use the exclamation point for now...
		  			@error_message << ' ** [INFO] choice saved to database!'
	  			else
	  				@error_message << ' ** ERROR: could not save new choice'
	  				next # can't store the new choice in the inclusions table if could not save the entity itself!
				end
			end
			
	  		new_inclusion = Inclusion.new(:question_id => question_id,:choice_id => (existing_choice.nil? ? @new_choice.id : existing_choice.id))
	  		if new_inclusion.save # use the exclamation point for now...
		  		@error_message << ' !! [INFO] inclusion saved to database!'
	  		else
	  			@error_message << ' !! ERROR: could not save new inclusion'
	  		end
		end
	end
	
	
	def _get_current_question_and_choices(question_id)	  	
	  	# do I need to check the id here? won't the clause escape it? also - if it is null, then won't find anything	
	  	# all of the following is basically from edit... its the SAME
	  	@question = Question.where("id = ?",question_id).first
	  	if @question.nil?
	  		respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
  		end
  		
  		question_choice_ids = Inclusion.where('question_id = ?',@question.id).order('updated_at ASC') # NOTE: to preserve the order the user had, must keep like this!!!
  		if question_choice_ids.nil? # might not need this
  			respond_to do |format|
	  			format.html { redirect_to root_url }
	  		end
	  		return
  		end
  		
  		# like in other cases, could replace with a join instead of repeated ones
  		current_choice_ids = question_choice_ids.all.collect { |q| q.choice_id.to_i }
  		@current_options = []
  		current_choice_ids.each do |choice|
  			choice_row = Choice.where('id = ?',choice).first
  			if not choice_row.nil?
  				@current_options << choice_row.value
  			else
  				@current_options << 'nil choice' # TODO: add better error
  			end
  		end 
	end	
end
