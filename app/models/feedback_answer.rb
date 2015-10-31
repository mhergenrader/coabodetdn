class FeedbackAnswer < ActiveRecord::Base
	
	attr_accessible :response, :comments, :respondent_id, :about_id, :question_id, :job_id
	
	belongs_to :profile, :foreign_key => :respondent_id
	belongs_to :question
	belongs_to :job	
end
