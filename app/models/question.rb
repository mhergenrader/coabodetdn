class Question < ActiveRecord::Base
	validates :short_name, :presence => true
	validates :text, :presence => true
	
	PROFILE_DOMAIN = 'profile'
	FEEDBACK_DOMAIN = 'feedback'
	UNFILED_DOMAIN = 'unfiled'
	
	attr_accessible :short_name, :text, :question_type, :domain, :created_by, :updated_by, :created_at, :updated_at
	
	#enum_attr :type, %w(multiple_choice multiple_selection text)
	
	has_many :answers # this could be used by administrators for analytics purposes, retrieving all answers to a particular question (or for screening)
		
	#belongs_to :option_set
	has_many :inclusions
	has_many :choices, :through => :inclusions
	
	has_many :feedback_questions # one question can be a part of many feedback forms
	has_many :feedback_forms, :through => :feedback_questions
	
	belongs_to :user
	
end
