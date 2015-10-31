class ProfilesController < ApplicationController
	
  # GET /profiles/
  def index
  	if not user_signed_in? # if user is not signed in, they should not be allowed to view this page or be redirected
  		respond_to do |format|
  			format.html { redirect_to root_url }
  		end
  		return
  	end
  	
  	user_profile = Profile.where('user_id = ?',current_user.id).first
  	if user_profile.nil? # user has not yet set up a profile - create a blank new one for them
  		@profile = Profile.new
  		@profile.user_id = current_user.id
  		@profile.save
  		redirect_to "/profiles/#{@profile.id}"
  	else
  		redirect_to "/profiles/#{user_profile.id}"
  	end # only job of index is to be a directory to the user's profile
  end
  
    
  # GET /profiles/:id
  def show
  	if not user_signed_in? # if user is not signed in, they should not be allowed to view this page
  		respond_to do |format|
  			format.html { redirect_to root_url }
  		end
  		return
  	end  	
  	
  	begin # if user is signed in, check that the supplied id actually matches a user
  		@user_profile = Profile.find(params[:id])
  	rescue ActiveRecord::RecordNotFound
  		respond_to do |format|
  			format.html { redirect_to root_url }  # just for now
  		end  		
  		return
  	end
  	
  	@my_own_profile = Profile.where('user_id = ?',current_user.id).first
	@allow_edit = (@user_profile.user_id.to_i == current_user.id.to_i) # determine whether or not the user can edit/create anything in the profile 
  		
  	@image = Image.where('profile_id = ? AND profile_picture = ?',@user_profile.id,true).first
  		
  	@user = User.where('id = ?',@user_profile.user_id).first # for generating the account information
  	
  	@all_user_answers = Answer.where("profile_id = ?",@user_profile.id).all  	
  	@all_user_answer_ids = @all_user_answers.collect { |a| a[:question_id].to_i }  	
  	@all_question_ids = Question.select("id").where('domain = ?',Question::PROFILE_DOMAIN).collect { |q| q[:id].to_i } # find first unanswered question for the profile - generate link to it  	
  	@all_answered_question_ids = @all_user_answer_ids & @all_question_ids # result of the previous!
  	
  	@profile_exists = (@all_answered_question_ids.length > 0) # displays profile or recommends that the user create one (or if id is not mine, then specify that current user does not have profile)
  	
  	# this field is calculated no matter what - whether a profile exists or not
  	unanswered_question_ids = @all_question_ids - @all_user_answer_ids	
  	@first_question_id = (unanswered_question_ids.empty? ? @all_question_ids.min.to_i : unanswered_question_ids.min.to_i)
  	
  	
  	@all_unanswered_questions = [] # TODO: improve this performance in particular - avoid so many queries
  	unanswered_question_ids.each do |q|
  		question = Question.where('id = ?',q).first
  		if not question.nil?
  			@all_unanswered_questions << { :id => question.id, :short_name => question.short_name, :question => question.text } # can combine all of this?
  		end
  	end
  	
  	@all_qa_pairs = [] # gather all current responses by this user (array of hashes) - these are for questions that exist!
  	@all_user_answers.each do |a|
  		question = Question.where('id = ?',a.attributes['question_id']).first
  		if not question.nil? # original colors (respectively: warning, success)
  			@all_qa_pairs << { :question => question.text, :short_name => question.short_name, :response => (question.question_type == 'MS' ? a.response.gsub('##',', ') : a.response), :comments => a.comments, :id => question.id, :button_type => ((a.comments.empty? or a.response.empty?) ? 'warning' : 'success') } # last one colors the buttons based on if something is missing (can make it a warning if just the response is missing...)
  		end
	end  	
	@all_qa_pairs.sort! { |i,j| i[:short_name].to_s <=> j[:short_name].to_s } # put in alphabetical order so easier to see
	
	@all_orphaned_answer_ids = @all_user_answer_ids - @all_question_ids # show the answers that no longer have an associated question
	
	@images = Image.where('profile_id = ?',@user_profile.id).all # TODO: add condition to eliminate profile picture
	@image_count = Image.where('profile_id = ? AND name <> ?',@user_profile.id,'no_profile_image').count # don't make this a separate query
		
	@user_postings = Job.where('user_id = ?',@user_profile.user_id).all
	
	# generate all resumes for div
	@resumes = Resume.where('profile_id = ?',@user_profile.id).all
	@resume_count = @resumes.length
	
	
	all_feedback_answers = FeedbackAnswer.where('about_id = ?',@user_profile.id).order('question_id').all # sort by question	
	@feedback_answers_by_question = {}
	
	all_feedback_answers.each do |answer|
		@feedback_answers_by_question[answer.question_id] = [] # create blank entries initially for every question
	end
	
	all_feedback_answers.each do |answer| # transform the list into a question groups, each containing answers from various users
		@feedback_answers_by_question[answer.question_id] << { :response => answer.response.gsub('##',', '), :comments => answer.comments, :respondent_id => answer.respondent_id, :submitted_at => answer.updated_at } # include the job that was completed also?
	end
	
	
	
  end
  
  
  
 def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  
  # PUT /profiles/:id
  def update
  	redirect_to { profile_path }
  	return
  end
  
  
  # POST /profiles
  def create
  end
  
  
  # GET /profiles/:id/edit
  def edit
  end
  
  
  # DELETE /profiles/:id
  def destroy
  	if not user_signed_in? # if user is not signed in, they should not be allowed to view this page
  		respond_to do |format|
  			format.html { redirect_to root_url }
  		end
  		return
  	end
  	  	
  end
  
  # GET /profiles/new
  def new
  end
  
  
  def not_found
	raise ActionController::RoutingError.new('Profile not found') # in case a user does not want to be searched - redirect whoever is looking to this page
  end
  
  
  
end