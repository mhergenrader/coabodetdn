class FeedbackFormsController < ApplicationController
	#load_and_authorize_resource # todo once complete

	def index		
		@all_forms = FeedbackForm.select('id,name,description').all		
	end
	
	
	def new
		all_forms = FeedbackForm.select('name,description').all
		@form_names = "[#{all_forms.collect { |f| "\"#{f.name}\"" }.compact.join(',')}]"
		@form_descriptions = "[#{all_forms.collect { |f| "\"#{f.description}\"" }.compact.join(',')}]"
		
		@questions = Question.select('id,short_name,text,question_type').where('domain = ?',Question::FEEDBACK_DOMAIN).all # to create the drag and drop lists		
		@new_question = Question.new # for the partial (not sure if will keep this)
		
		@question_parts = "[#{@questions.collect { |q| "\"#{q.short_name}\"" }.compact.join(',')}]" # just filter by name for now
		
		#@question_parts = "[#{@questions.collect { |q| "\"#{q.short_name}\"" + ",\"#{q.text}\"" }.compact.join(',')}]"
		#@question_texts = "[#{@questions.collect { |q| "\"#{q.text}\"" }.compact.join(',')}]"
		
		@form = FeedbackForm.new
	end
	
	
	def create
		# for now: (while testing new system)
		@params = params
		#return
		
  		if params[:feedback_form][:name].nil? or params[:feedback_form][:name].empty?
  			@error_message = 'ERROR: no feedback form name provided'
  		#elsif params[:feedback_form][:description].nil? or params[:feedback_form][:description].empty?
  		#	@error_message = 'ERROR: no question text provided'
  		elsif params[:all_questions].nil? or params[:all_questions].empty?
  			@error_message = 'ERROR: no questions were specified for this form'
  		else
  			description = params[:feedback_form][:description]
  			if description.nil?
  				description = ''
  			end
  			  			
  			# first create the form itself, then add the question relationships
  			@feedback_form = FeedbackForm.new(:name => params[:feedback_form][:name], :description => description, :created_by => current_user.id, :updated_by => current_user.id)
  			if not @feedback_form.save!
  				@error_message = 'ERROR: could not save record to database'
  			end
  			
  			# help prevent duplicate records
  			ActiveRecord::Base.connection.execute("DELETE FROM feedback_questions WHERE feedback_form_id = #{@feedback_form.id.to_i}") # better way?
  			 			
  			if @error_message.nil?
  				@error_message = ''
  			end
  			
  			# force javascript for the new/edit page
  			
  			# add all connections between questions and feedback forms
  			@question_ids = params[:all_questions]
  			@new_questions = params[:new_questions]
			@question_ids.each do |question_id|				
		  		# check if there are any new questions first - if so, create them and replace the short name with the new id from the table		  		
		  		# new questions will be of the form "question_[short_name]", while old questions will just be a number
		  		# the following method is safer than just checking index of _, as input might come from a REST api and not just a webpage form!

		  		current_question_id = nil
		  		begin
		  			parsed_value = Integer(question_id)
		  			current_question = Question.select('id').where('id = ?',parsed_value).first # make sure that the current question exists - can remove?
		  			if current_question.nil?
		  				@error_message << " !! ERROR: invalid question parameter - question #{question_id} for existing question does not exist"
		  				next
	  				end
	  				current_question_id = current_question.id
  				rescue ArgumentError # could not convert to an integer, so trying to create a new question
	  				current_question_id = _validate_and_create_new_question(question_id)
	  				if current_question_id.nil?
	  					next
  					end  				
  				end  				
				
				new_feedback_question = FeedbackQuestion.new(:feedback_form_id => @feedback_form.id, :question_id => current_question_id.to_i) # :question_id => question_id.to_i)
		  		if new_feedback_question.save # use the exclamation point for now...
			  		@error_message << ' !! [INFO] feedback question saved to database!'
		  		else
		  			@error_message << ' !! ERROR: could not save new feedback question relationship'
		  		end
			end  			
  		end
  		
  		if @error_message.nil? or @error_message.index('ERROR').nil? # if there is an error, stay on this page; else, allow user to continue
  			redirect_to :action => :index
  		end
	end
	
	
	def edit
		@form = FeedbackForm.where('id = ?',params[:id]).first
		if @form.nil?
			redirect_to root_url # just for now
		end
		
		all_forms = FeedbackForm.select('name,description').all
		@form_names = "[#{all_forms.collect { |f| "\"#{f.name}\"" }.compact.join(',')}]"
		@form_descriptions = "[#{all_forms.collect { |f| "\"#{f.description}\"" }.compact.join(',')}]"
		
		all_questions = Question.select('id,short_name,text,question_type').where('domain = ?',Question::FEEDBACK_DOMAIN).all # to create the drag and drop lists
		@question_parts = "[#{all_questions.collect { |q| "\"#{q.short_name}\"" }.compact.join(',')}]" # just filter by name for now
		
		@new_question = Question.new
		
		# get questions currently stored for this form
		@feedback_questions = [] # array of specialized hashes
		@non_feedback_questions = [] # array of question objects		
		@feedback_questions_hash = {}
		
		feedback_questions = FeedbackQuestion.select('question_id,updated_at').where('feedback_form_id = ?',@form.id).all
		feedback_questions.each do |q|
			@feedback_questions_hash[q.question_id] = q.updated_at.to_f # gross, but this fixes it (need it to compare)
		end
		
		all_questions.each do |question|
			if @feedback_questions_hash.keys.include?(question.id)
				modified_question = { :id => question.id, :short_name => question.short_name, :text => question.text, :question_type => question.question_type, :updated_at => @feedback_questions_hash[question.id] }
				@feedback_questions << modified_question
			else
				@non_feedback_questions << question
			end
		end		
		
		@feedback_questions.sort! { |a,b| a[:updated_at] <=> b[:updated_at] } # sort this hash by updated at	
	end
	
	
	def show
		@form = FeedbackForm.where('id = ?',params[:id]).first
		if @form.nil?
			redirect_to root_url # just for now
		end
		
		form_question_ids = FeedbackQuestion.where('feedback_form_id = ?',@form.id).order('updated_at ASC').all.collect { |q| q.question_id }.compact # fixed order issue by using time
		@current_form_questions = []
		form_question_ids.each do |form_question_id|
			current_question = Question.select('id,short_name,text,question_type').where('id = ?',form_question_id).first
			if not current_question.nil?
				@current_form_questions << current_question
			end
		end
	end
	
	
	def update
		# TODO: make sure that there are no duplicates for feedback forms	  		
	  	@params = params # for debugging in case of errors (see update.html.erb)
	  	
	  	if params[:feedback_form][:name].nil? or params[:feedback_form][:name].empty?
  			@error_message = 'ERROR: no feedback form name provided'
  		elsif params[:all_questions].nil? or params[:all_questions].empty?
  			@error_message = 'ERROR: no questions were specified for this form'
  		else
  			description = params[:feedback_form][:description]
  			if description.nil?
  				description = ''
  			end
  			
  			# since this is an idempotent action, must first check to see if it exists (the resource)
  			current_feedback_form = FeedbackForm.where('id = ?',params[:id]).first
  			if current_feedback_form.nil? # doesn't already exist: first create the form itself, then add the question relationships
  				@feedback_form = FeedbackForm.new(:name => params[:feedback_form][:name], :description => description, :created_by => current_user.id, :updated_by => current_user.id)
  				if not @feedback_form.save!
  					@error_message = 'ERROR: could not save new feedback form to database'
  				end
  			else
  				@feedback_form = FeedbackForm.update(current_feedback_form.id.to_i, :name => params[:feedback_form][:name], :description => params[:feedback_form][:description], :updated_by => current_user.id) # updated_at will be done automatically by Rails
  			end
  			
  			# help prevent duplicate records - must replace all existing relationships with questions
  			ActiveRecord::Base.connection.execute("DELETE FROM feedback_questions WHERE feedback_form_id = #{@feedback_form.id.to_i}") # better way?
  			
  			if @error_message.nil?
  				@error_message = ''
  			end
  			
  			# add all connections between questions and feedback forms
  			@question_ids = params[:all_questions]
  			@new_questions = params[:new_questions]
			@question_ids.each do |question_id|				
				# check if there are any new questions first - if so, create them and replace the short name with the new id from the table		  		
		  		# new questions will be of the form "question_[short_name]", while old questions will just be a number
		  		# the following method is safer than just checking index of _, as input might come from a REST api and not just a webpage form!

		  		current_question_id = nil
		  		begin
		  			parsed_value = Integer(question_id)
		  			current_question = Question.select('id').where('id = ?',parsed_value).first # make sure that the current question exists - can remove?
		  			if current_question.nil?
		  				@error_message << " !! ERROR: invalid question parameter - question #{question_id} for existing question does not exist"
		  				next
	  				end
	  				current_question_id = current_question.id
  				rescue ArgumentError # could not convert to an integer, so trying to create a new question
	  				current_question_id = _validate_and_create_new_question(question_id)
	  				if current_question_id.nil?
	  					next
  					end  				
  				end				
				
				new_feedback_question = FeedbackQuestion.new(:feedback_form_id => @feedback_form.id, :question_id => current_question_id.to_i)
		  		if new_feedback_question.save # use the exclamation point for now...
			  		@error_message << ' !! [INFO] feedback question saved to database!'
		  		else
		  			@error_message << ' !! ERROR: could not save new feedback question relationship'
	  			end
			end
  		end
  		
  		if @error_message.nil? or @error_message.index('ERROR').nil? # if there is an error, stay on this page; else, allow user to continue
  			redirect_to :action => :index
  		end
	end
	
	
	def destroy
		# perform destruction - TODO		
		respond_to do |format|
			format.html { redirect_to feedback_forms_path }
		end
	end
	
	
	private	
	
	# returns the newly created question or nil if there was a problem
	def _validate_and_create_new_question(question_id)
		if not question_id.start_with? 'question_'
			@error_message << " !! ERROR: invalid question parameter for new question: #{question_id}" # might not need to do this
			return nil
		end
		current_question_name = question_id.split('_')[1] # pull out the question short name
		if current_question_name.nil?
			@error_message << " !! ERROR: blank question name parameter provided"
			return nil
		end
		
		if not @new_questions.has_key?(current_question_name) # this is an optional check - this adds only questions that were added to the right side (not an error, just a convention)
			return nil
		end
		
		current_question_attrs = @new_questions[current_question_name] # but if there is a question name, then it must have attributes
		if current_question_attrs.nil?
			@error_message << ' !! ERROR: no question attrs provided for ' + current_question_name
			return nil
		end
		
		# question now has attributes established, so validate them
		if current_question_attrs['text'].nil? or current_question_attrs['text'].empty?
			@error_message << ' !! ERROR: no question text provided for ' + current_question_name
			return nil
		end
		if current_question_attrs['question_type'].nil? or current_question_attrs['question_type'].empty?
			@error_message << ' !! ERROR: no question type provided for ' + current_question_name
			return nil
		end
		
		current_question_type = _condense_question_type(current_question_attrs['question_type'])
		
		# finally, check the type - if it is not textual, then check for params
		if current_question_type != 'TEXT'
			if current_question_attrs['choices'].nil? or current_question_attrs['choices'].empty?
				@error_message << ' !! ERROR: no choices provided for mc/ms question ' + current_question_name
				return nil
			end
		end
		
		# the question has been validated, so it can now be created
		new_question = Question.new(:short_name => current_question_name, :text => current_question_attrs['text'], :question_type => current_question_type, :created_by => current_user.id, :updated_by => current_user.id, :domain => 'feedback')
	  	if new_question.save
	  		@error_message << ' [INFO] new question ' + current_question_name + ' saved to database!'
  		else
  			@error_message << ' !! ERROR: could not save new question with name ' + current_question_name
  			return nil
  		end
  		
  		if current_question_type != 'TEXT' # if this was a choice question, store the choices
  			_update_current_choices_and_inclusions(new_question.id,current_question_attrs['choices'])
		end		
		
		new_question.id
	end
	
	# text transformation from the displayed question type to the database one (same as method from questions) - should make a module to mix into both
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
	
	# add any new choices the user specified to the Choice table and add any new Choice-Question relationships to the Inclusion model
	# similar to the Question private method (functionality is the same)
	def _update_current_choices_and_inclusions(question_id, choices)
		choices.each do |choice|			
			existing_choice = Choice.where('value = ?',choice).first # check first if this option already exists to help prevent duplicate choices		
			if existing_choice.nil? # if doesn't already exist, store it
				new_choice = Choice.new(:value => choice)
				if new_choice.save
		  			@error_message << ' ** [INFO] choice saved to database!'
	  			else
	  				@error_message << ' ** ERROR: could not save new choice'
	  				next
				end
			end
			
	  		new_inclusion = Inclusion.new(:question_id => question_id,:choice_id => (existing_choice.nil? ? new_choice.id : existing_choice.id))
	  		if new_inclusion.save # use the exclamation point for now...
		  		@error_message << ' !! [INFO] inclusion saved to database!'
	  		else
	  			@error_message << ' !! ERROR: could not save new inclusion'
	  		end
		end
	end
	
end
