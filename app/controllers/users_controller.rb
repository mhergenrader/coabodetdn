class UsersController < Devise::RegistrationsController
  def index
	@user = User.find(current_user.id)
	render :show
  end
  
  def allusers
	@users = User.all
  end
  
  def allusers_advanced
	@users = User.all
  end
  
  def new
	super

  end

  def edit
	super
  end

  def show
  end

  def delete
  end
  
  def search
    @users = User.search(params[:search], params[:page])
  end

end
