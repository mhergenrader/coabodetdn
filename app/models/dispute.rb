class Dispute < ActiveRecord::Base

belongs_to :user, :foreign_key => :owner_id
belongs_to :job, :foreign_key => :service_id


attr_accessible :owner_id, :offender_id, :service_id, :description

validates :offender_id, :presence => true
validate :owner_not_offender

def owner_not_offender
	if owner_id == offender_id
		errors.add(:offender_id, " cannot be the same as owner")
	end
end



end
