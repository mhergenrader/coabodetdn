class FeedbackForm < ActiveRecord::Base
	
	PEER_TO_PEER_TYPE = 'peer'
	COABODE_SITE_TYPE = 'site'
	TESTING_SITE_TYPE = 'test'
	
	attr_accessible :id, :name, :description, :created_by, :updated_by, :created_at, :created_by
	
	belongs_to :user
	
	# eventually has many responses (can reuse answers table?)
	
	has_many :feedback_questions # one feedback form can consist of many questions
	has_many :questions, :through => :feedback_questions	
end
