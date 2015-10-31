class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :first_name, :middle_name, :last_name, :ethnicity, :date_of_birth, :city, :state, :zip_code
  
  
  has_many :jobs
  has_many :job_applications, :class_name => "JobApplicant", :foreign_key => "applicant_id"
  has_many :incoming_transactions, :class_name => "Transaction", :foreign_key => "receiver_id"
  has_many :outgoing_transactions, :class_name => "Transaction", :foreign_key => "sender_id"
  has_many :sent_messages, :class_name => "Message", :foreign_key => "from"
  has_many :received_messages, :class_name => "MessageCopy", :foreign_key => "recipient_id"
  has_many :notifications
  has_many :relationships, :foreign_key => "follower_id",
                           :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  
  has_many :reverse_relationships, :foreign_key => "followed_id",
                                   :class_name => "Relationship",
                                   :dependent => :destroy
  has_many :followers, :through => :reverse_relationships, :source => :follower
  
  
  has_and_belongs_to_many :roles, :join_table => 'users_roles'
  
  before_create :setup_role
  after_create :initialize_td, :build_the_profile 



  
  validates :username, :first_name, :last_name, :ethnicity, :city, :state, :zip_code, :presence => true
  validates_format_of :zip_code,:with => %r{\d{5}(-\d{4})?}, :message => "must be a valid, 5-digit number"
  
  has_one :profile
  
  has_many :questions, :foreign_key => 'created_by'
  has_many :feedback_forms, :foreign_key => 'created_by' # can specify multiple foreign keys?
  
  # TODO: add favorite users and/or friends (self join)
  # TODO: add blocked users (self join)
  
  def build_the_profile
	self.build_profile
	self.profile.user_id = self.id
  end
  
  def time_dollars
	return incoming_transactions.sum('amount') - outgoing_transactions.sum('amount', :conditions => ['is_system = ?',false])
  end
  
  def time_dollars_aside_for_posted_jobs
	return jobs.sum('price')
  end
  
  
  def unread_notifications
	return notifications.where(:read => nil).count
  end
  
  
  def unread_messages
	return received_messages.where(:read => nil).count
  end
  
  def role?(role_sym)
     roles.any? { |r| r.name.underscore.to_sym == role_sym }
  end
  
  def set_role(role_id) 
	self.roles = [Role.find(role_id)]
  end
  
  def setup_role
	#if self.roles == nil #todo
		self.roles = [Role.find_by_name('registered')] 
	#end
  end
  
  def initialize_td
	t = Transaction.new
	#puts "~~~~~~~~~~~~~~~~~~Made new transaction~~~~~~~~~~~~~~~~~~"
	t.is_system = true
	t.to = self
	t.amount = 5
	t.save
	#puts "~~~~~~~~~~~~~~~~~~saved new transaction~~~~~~~~~~~~~~~~~~"
  end
  
  def self.search(search, page)
  if search
	paginate :per_page => 5, :page => page,
           :conditions => ['username like ? or first_name like ?or last_name like ? or email like ?', "%#{search}%", "%#{search}%", "%#{search}%", "%#{search}%"],
           :order => 'username'
  else
    paginate :per_page => 5, :page => page,
           :order => 'username'
  end
end

  def transactions
	return incoming_transactions + outgoing_transactions
  end

  def following?(followed)
    relationships.find_by_followed_id(followed)
  end

  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed).destroy
  end
  
  def to_s
	return (username != nil and username != "") ? username : email
  end
  
end
