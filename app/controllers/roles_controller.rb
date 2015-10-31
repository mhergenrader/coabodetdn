class RolesController < ApplicationController
	load_and_authorize_resource
	
  # GET /roles
  # GET /roles.json
  def index
    @roles = Role.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @roles }
    end
  end
    
  def set
  		@roles = Role.all
		@user = User.find(current_user.id)
	if params[:role]
		
		@user.set_role(params[:role])
		@user.save
		respond_to do |format|
		  format.html { render action: "set", notice: 'Role was successfully saved .'}
		end
	else 
		respond_to do |format|
		  format.html # index.html.erb
		end
	end
  end

  # GET /roles/1
  # GET /roles/1.json
  def show
    @role = Role.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.json
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end

  # POST /roles
  # POST /roles.json
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        format.html { redirect_to @role, notice: 'Role was successfully created.' }
        format.json { render json: @role, status: :created, location: @role }
      else
        format.html { render action: "new" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.json
  def update
    @role = Role.find(params[:id])

    respond_to do |format|
      if @role.update_attributes(params[:role])
        format.html { redirect_to @role, notice: 'Role was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.json
  def destroy
    @role = Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to roles_url }
      format.json { head :ok }
    end
  end
  
  def choose_user_and_set_role
	@roles = Role.all
	if params[:role] #and params[:id]
		respond_to do |format|
			@user = User.find(params[:user][:id])
			@user.set_role(params[:role])
			@user.save
		    format.html { redirect_to root_url, notice: 'Role was successfully saved .'}
		end
	else 
		respond_to do |format|
		  format.html # index.html.erb
		end
	end
  end
  
  def set_user_role 
	@roles = Role.all
	@user = User.find(params[:id])
	if params[:role]
		
		@user.set_role(params[:role])
		@user.save
		respond_to do |format|
		  format.html { render action: "set_user_role", notice: 'Role was successfully saved .'}
		end
	else 
		respond_to do |format|
		  format.html # index.html.erb
		end
	end
  end
end
