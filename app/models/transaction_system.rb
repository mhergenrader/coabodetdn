class SystemTransaction < ActiveRecord::Base

	belongs_to :to, :class_name => "User", :foreign_key => :receiver_id
	validates :amount, :numericality => {:greater_than_or_equal_to => 0.01}
	
end
