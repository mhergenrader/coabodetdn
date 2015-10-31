require 'file_size_validator'
class Resume < ActiveRecord::Base	
	attr_accessible :profile_id, :name, :resume, :resume_description
	belongs_to :profile
	mount_uploader :resume, ResumeUploader
	
	validates :name, :presence => true
	validates :resume, :presence => true, :file_size => { :maximum => 2.megabytes.to_i }
end
