
class Message < ActiveRecord::Base
	
	belongs_to :author, :class_name => "User", :foreign_key => :from
	has_one :thread, :class_name => "Message", :foreign_key => :thread_id
	has_many :message_copies
	has_many :recipients, :through => :message_copies

	before_create :prepare_copies
	
	attr_accessor :to
	attr_accessible :title, :content, :to
	
	def prepare_copies
		return if to.blank?
		
		
		bad_entries = Array.new
		
		to.each do |r|
			name = r.strip()
			r = User.find_by_email(r.strip())	
			if r == nil
				r = User.find_by_username(name) # maybe its a username!
				if r == nil
					errors.add :to, "Did not find user: " + name
					raise "UserNotFoundError"
				end
			end
			message_copies.build(:recipient_id => r.id, :created_at => Time.now)
			
			
		
		end
	end
	
	
	
end
