class Choice < ActiveRecord::Base
	has_many :inclusions
	has_many :questions, :through => :inclusions	
end
