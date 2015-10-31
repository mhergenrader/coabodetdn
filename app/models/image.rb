require 'file_size_validator'
class Image < ActiveRecord::Base
	attr_accessible :profile_id, :name, :image, :profile_picture, :image_description
	belongs_to :profile
	mount_uploader :image, ImageUploader
	
	validates :name, :presence => true
	#validates_format_of :name, :with => %r{[-A-Za-z0-9_!?]+}, :message => "must contain basic characters" # must test this - can lift later
	validates :image, :presence => true, :file_size => { :maximum => 2.megabytes.to_i }
end
