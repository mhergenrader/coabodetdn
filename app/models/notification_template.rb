class NotificationTemplate < ActiveRecord::Base

	#NotificationTemplate
	
	#method:string - where the notification is created
	#model:string - what are we working with
	#to_attr:string - the attribute of the user that returns the user_id 
	#link_attr:string - the attribute to link to
	
	#Notification
	#user_id: integer who's notification
	#lookup_id: integer
	#message: string notification
	#inner_links: string
	#link_id: integer 
	#template_id: integer 



	#todo validate @whatever by Model.respond_to?('attribute')
	def build_notification()
		@matches = template.scan(/@[a-zA-Z_]+/)
		@model = model.constantize #get the model we are going to work with
		@lookup = @model.find(:last) #TODO could be wrong, because the controller could fail
		#assumes only 1 user gets it
		#if(!Notification.find_by_id(@lookup.id)) NOT RIGHT 
			@notification = Notification.new #create new one
			@notification.lookup_id = @lookup.id
			@notification.message = template
			@notification.template = self
			@notification.type = model
			
			@matches.each do |match| #for every match in the template, it must be an attribute of the model.
				attr = match[1, match.size].to_sym
				#if(@model.instance_methods.include?(attr)) #if it is a attribute, then look for first instance of 
				if(@lookup.respond_to?(attr))
					#do a .to_s, because it will get what we want
					#logger.info "Here it is1"
					replacement = @lookup.send(attr).to_s #invokes whatever attribute it is
					@notification.message = @notification.message.sub(match, replacement)
					
					# find for first instance of match in template, replace with @record.send(attr)
					#TODO: link if i can? I have no idea how to provide a link at this stage
				end
			end
			  
			  #@notification.message = template #update the template
			  if link_attr.to_sym != :self
				@notification.link_id = @lookup.send(link_attr.to_sym).id
			  else
				@notification.link_id = @lookup.id
			  end
			  
			  @notification.user_id = @lookup.send(to_attr.to_sym).id
			  @notification.save
			
			
		# end
	end
	
	#todo validate @whatever by Model.respond_to?('attribute')
	def build_notification_by_id(id)
		@matches = template.scan(/@[a-zA-Z_]+/)
		@model = model.constantize #get the model we are going to work with
		@lookup = @model.find_by_id(id) #TODO could be wrong, because the controller could fail
		#assumes only 1 user gets it
		#if(!Notification.find_by_id(@lookup.id)) NOT RIGHT 
			@notification = Notification.new #create new one
			@notification.lookup_id = @lookup.id
			@notification.message = template
			@notification.template = self
			@notification.type = model
			
			@matches.each do |match| #for every match in the template, it must be an attribute of the model.
				attr = match[1, match.size].to_sym
				#if(@model.instance_methods.include?(attr)) #if it is a attribute, then look for first instance of 
				#logger.info "Here it is"
				#logger.info @lookup 
				
				if(@lookup.respond_to?(attr))
					#do a .to_s, because it will get what we want
					replacement = @lookup.send(attr).to_s #invokes whatever attribute it is
					@notification.message = @notification.message.sub(match, replacement)
					
					# find for first instance of match in template, replace with @record.send(attr)
					#TODO: link if i can? I have no idea how to provide a link at this stage
				end
			end
			  
			  #@notification.message = template #update the template
			  if link_attr.to_sym != :self
				@notification.link_id = @lookup.send(link_attr.to_sym).id
			  else
				@notification.link_id = @lookup.id
			  end
			  
			  @notification.user_id = @lookup.send(to_attr.to_sym).id
			  @notification.save
			
			
		# end
	end
	
	
	
	
	
	
	
	
	
	def to_s
		return template
	end
	
end
