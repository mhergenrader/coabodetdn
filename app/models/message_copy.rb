class MessageCopy < ActiveRecord::Base
	belongs_to :message
	belongs_to :recipient, :class_name => "User"
	delegate :author, :created_at, :title, :content, :recipients, :to => :message
end
