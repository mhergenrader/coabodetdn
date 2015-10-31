class Transaction < ActiveRecord::Base
	belongs_to :from, :class_name => "User", :foreign_key => :sender_id
	belongs_to :to, :class_name => "User", :foreign_key => :receiver_id
	belongs_to :job, :foreign_key => :service_id
	validate :sender_not_receiver
	validates :amount, :numericality => {:greater_than_or_equal_to => 0.01}
	validate :has_enough_time_dollars
	validate :system_not_nil
	
	def sender_not_receiver
		if !is_system and from == to
			errors.add(:receiver_id, " cannot be the same as sender")
		end
	end
	
	def has_enough_time_dollars
		if amount.nil?
			errors.add(:amount, " must have a value")
		elsif !is_system and amount > from.time_dollars
			errors.add(:amount, " must be less than or equal to your supply of Time Dollars")
		end
	end
	
	def system_not_nil
		self.is_system = false if self.is_system.nil?
	end
	
	def created_date_only
		created_at.to_date
	end
	
	def to_s
		return amount.to_s
	end
	

end
