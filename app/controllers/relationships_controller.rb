class RelationshipsController < ApplicationController

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
	@profile = Profile.where('user_id = ?',@user.id).first
    respond_to do |format|
      format.html { redirect_to @profile }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
	@profile = Profile.where('user_id = ?',@user.id).first
    respond_to do |format|
      format.html { redirect_to @profile }
      format.js
    end
  end
end