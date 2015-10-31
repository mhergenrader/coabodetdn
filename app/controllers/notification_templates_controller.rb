class NotificationTemplatesController < ApplicationController
  authorize_resource
  # GET /notification_templates
  # GET /notification_templates.json
  def index
    @notification_templates = NotificationTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @notification_templates }
    end
  end

  # GET /notification_templates/1
  # GET /notification_templates/1.json
  def show
    @notification_template = NotificationTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @notification_template }
    end
  end

  # GET /notification_templates/new
  # GET /notification_templates/new.json
  def new
    @notification_template = NotificationTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @notification_template }
    end
  end

  # GET /notification_templates/1/edit
  def edit
    @notification_template = NotificationTemplate.find(params[:id])
  end

  # POST /notification_templates
  # POST /notification_templates.json
  def create
    @notification_template = NotificationTemplate.new(params[:notification_template])
	@notification_template.max_arguments = @notification_template.template.scan(/@[a-zA-Z]+/).size()
    respond_to do |format|
      if @notification_template.save
        format.html { redirect_to @notification_template, notice: 'Notification template was successfully created.' }
        format.json { render json: @notification_template, status: :created, location: @notification_template }
      else
        format.html { render action: "new" }
        format.json { render json: @notification_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /notification_templates/1
  # PUT /notification_templates/1.json
  def update
    @notification_template = NotificationTemplate.find(params[:id])
	@notification_template.max_arguments = params[:notification_template][:template].scan(/@[a-zA-Z]+/).size()
    respond_to do |format|
      if @notification_template.update_attributes(params[:notification_template])
        format.html { redirect_to @notification_template, notice: 'Notification template was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @notification_template.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notification_templates/1
  # DELETE /notification_templates/1.json
  def destroy
    @notification_template = NotificationTemplate.find(params[:id])
    @notification_template.destroy

    respond_to do |format|
      format.html { redirect_to notification_templates_url }
      format.json { head :ok }
    end
  end
end
