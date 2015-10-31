class Answer < ActiveRecord::Base
	# TODO: add some validation

	attr_accessible :response, :comments, :question_id, :profile_id, :created_at, :updated_at
	
	belongs_to :question
	belongs_to :profile
	belongs_to :dispute
end
