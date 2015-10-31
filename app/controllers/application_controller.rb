class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :mailer_set_url_options
  
  after_filter do |controller, action|
	logger.info controller.controller_name + "." + controller.action_name
	check_notify(controller.controller_name + "." + controller.action_name)
  end
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access denied."
    redirect_to root_url
  end
  

  def mailer_set_url_options
	ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  def check_notify(method)

	if user_signed_in?
		@nt = NotificationTemplate.find_by_method(method)
		if @nt != nil
			if(params[:id] != nil and (@nt.use_id_param))
				@nt.build_notification_by_id(params[:id])
			else
				@nt.build_notification
			end
		end
	end
	#logger.info NotificationTemplates.all
  end
  
  
end
