class Profile < ActiveRecord::Base	
	#accepts_nested_attributes_for :answers

	belongs_to :user	
	has_many :answers	
	has_many :images
	has_many :resumes
end
