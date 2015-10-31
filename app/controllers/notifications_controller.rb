class NotificationsController < ApplicationController
	authorize_resource

  # GET /notifications
  # GET /notifications.json
  def index
	if current_user.role? :admin
		@notifications = Notification.all
	else
		@notifications = current_user.notifications.order("created_at DESC")
		@notifications.each  do |n| 
			n.read = true
			n.save
		end
	end
	
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notifications }
    end
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show
    @notification = Notification.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/new
  # GET /notifications/new.json
  def new
    @notification = Notification.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @notification }
    end
  end

  # GET /notifications/1/edit
  def edit
    @notification = Notification.find(params[:id])
  end

  # POST /notifications
  # POST /notifications.json
  def create
    @notification = Notification.new(params[:notification])
	@notification.user = User.find_by_username(params[:notification][:user_id])

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { render json: @notification, status: :created, location: @notification }
      else
        format.html { render action: "new" }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notifications/1
  # PUT /notifications/1.json
  def update
    @notification = Notification.find(params[:id])

    respond_to do |format|
      if @notification.update_attributes(params[:notification])
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    @notification = Notification.find(params[:id])
	
	if current_user == @notification.user or current_user.role? :admin
		@notification.destroy
		respond_to do |format|
		  format.html { redirect_to notifications_url }
		  format.json { head :ok }
		end
	else
		respond_to do |format|
		  format.html { redirect_to notifications_url, notice: "Trying to destroy other people's notifications are bad!" }
		  format.json { render json: @notification.errors, status: :unprocessable_entity  }
		end
		
	end 
	
	


  end
end
