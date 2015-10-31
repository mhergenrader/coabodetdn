class JobApplicant < ActiveRecord::Base
#class ServiceApplicant {
#    int service_id;   
#   User applicant;
#    boolean is_hired;
#	boolean is_paid;
#}
    

belongs_to :job, :foreign_key => :service_id #Job job;



 
belongs_to :applicant, :class_name => "User", :foreign_key => :applicant_id #User applicant;
    validate :validate_duplicated_application
    

def work_for
	return job.user
end

    #attr_accessible :name
    #name = applicant.first_name
    
#todo for kai
#setup rules here
   # validate :validate_duplicated_application, :message=>"You have applied this service before. You can't apply it again"
    
    #check duplicated application
    def validate_duplicated_application
      if job.job_applicants.exists?(:applicant_id => applicant.id) #21
          if is_hired == false
            errors.add(:job, "has been applied before. You can't apply it again")
          end
      end
  end
# on a create
# set is_hired == false
# set is_paid === true

end
