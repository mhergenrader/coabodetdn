class Job < ActiveRecord::Base
  belongs_to :user
  has_many :job_applicants, :foreign_key => :service_id
  validates :title, :description, :presence => true
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validate :has_enough_time_dollars   
    validate :validate_num_of_workers
  def self.search(search, page)
	  if search
		paginate :per_page => 5, :page => page,
			   :conditions => ['title like ? or description like ?', "%#{search}%", "%#{search}%"],
			   :order => 'created_at desc'
	  else
		paginate :per_page => 5, :page => page,
			   :order => 'created_at desc'
	  end
  end
  
  def has_enough_time_dollars
	if price.nil?
		errors.add(:price, " must have a value")
	elsif price > user.time_dollars - user.time_dollars_aside_for_posted_jobs
		errors.add(:price, " must be less than or equal to your supply of Time Dollars")
	end
  end

  def validate_num_of_workers
      if num_of_workers.nil?
          errors.add(:num_of_workers, "must have a value")
      elsif num_of_workers < 0
          errors.add(:num_of_workers, "must be greater than 0")
      end
  end

  
  def to_s 
	return title
  end
  
  def user_is_applicant(input_id)
	job_applicants.each do |x|
		if x.applicant_id == input_id
			return true
		end
	end
	return false
  end
  
  
end
