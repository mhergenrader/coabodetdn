class MessagesController < ApplicationController
  authorize_resource
  
  # GET /messages
  # GET /messages.json
  # displays the inbox
  def index
  @messages = current_user.received_messages 
 
  @messages = @messages.paginate(:page => params[:page], :per_page => 5, :order => "created_at DESC")
	#@messages = current_user.incoming_messages.find(:all, :order => "created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end
  
  # GET /messages
  # GET /messages.json
  # displays all sent messages
  def sent
    @messages = current_user.sent_messages.paginate(:page => params[:page], :per_page => 5, :order => "created_at DESC")
	
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @messages }
    end
  end
  
  # GET /messages
  # GET /messages.json
  # displays a sent message
  def show_sent
    @message = current_user.sent_messages.find(params[:id])
	
    respond_to do |format|
      format.html # show_sent.html.erb
      format.json { render json: @messages }
    end
  end
  
  
  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = current_user.received_messages.find(params[:id])
	
	if @message.read == nil
		@message.read = true
		@message.save
	end
	
	@reply = current_user.sent_messages.build
	@reply.title = @message.title.sub(/^(Re: )?/, "Re: ")
	@reply.content = @message.content.gsub(/^/, "> ")
	@reply.from = current_user.email
	@reply.to = @message.author.email
	
	
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @message }
    end
  end

  # GET /messages/new
  # GET /messages/new.json
  # creates a new message
  def new
    @message = current_user.sent_messages.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @message }
    end
  end


  
  def reply

  end

  # POST /messages
  # POST /messages.json
  def create

    @message = current_user.sent_messages.build(params[:message])
	@message.to = @message.to.split(",")
	
	
	
	begin
		success = @message.save
	rescue 
		@message.to = @message.to.join(",")
	end
	
	
	
    respond_to do |format|
      if success
		#TODO ugly hardcoding
        format.html { redirect_to "/messages/sent/" + @message.id.to_s, notice: 'Message was successfully created.' }
        format.json { render json: @message, status: :created, location: @message }
      else
        format.html { render action: "new", notice: 'Could not send your message.'}
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end


end
