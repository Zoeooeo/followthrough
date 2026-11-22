class UsersController < ApplicationController
  skip_before_action :require_sign_in
  before_action :redirect_if_signed_in

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      return_to = sign_in(@user)
      redirect_to return_to || root_path, notice: "Welcome to FollowThrough, #{@user.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
