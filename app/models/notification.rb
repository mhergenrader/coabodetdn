class Notification < ActiveRecord::Base

  def self.inheritance_column
    nil
  end
  
  def get_link
	@model =  template.model.constantize
	
	@attr = template.link_attr.to_sym
	
	if @attr != :self 
		@lookup = @model.find_by_id(lookup_id)
		return @lookup.send(@attr)
	else
		return @model.find_by_id(link_id)
	
	end
	
	
  end

belongs_to :user, :class_name => "User", :foreign_key => :user_id
belongs_to :template, :class_name => "NotificationTemplate", :foreign_key => :template_id

end
