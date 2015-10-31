class Ability
  include CanCan::Ability
  
  def initialize(user)
    user ||= User.new # guest user
    
    if user.role? :admin
      can :manage, :all
	  
	elsif user.role? :registered
	  can :create, JobApplicant
	  can :accept, Job
	  can :apply, Job
	  can :area, Job
	  can :read, Job
	  can :applied, Job
	  can :posted, Job
	  can :create, Job
      can :destroy, Job do |job|
      	job.try(:user) == user || user.role?(:admin)
  	  end
      can :update, Job do |job|
        job.try(:user) == user || user.role?(:admin)
      end
	  
	  can :read, Transaction do |t|
		t.try(:from) == user || user.role?(:admin) || t.try(:to) == user
	  end
	  can :create, Transaction 
	  can :reward, Transaction
      can :destroy, Transaction  do |t|
      	t.try(:from) == user || user.role?(:admin)
  	  end
      can :update, Transaction  do |t|
        t.try(:from) == user || user.role?(:admin)
      end
	  
	  can :read, Message
	  can :create, Message
	  can :show_sent, Message
	  can :sent, Message
	  
	  #Roles
	  can :show, Role
	  
	  #Notifications
	  can :read, Notification
	  can :destroy, Notification
	 
	  
	  
    else
      can :read, Job
      
	  
	  
	  
	  
    end
  end
end

