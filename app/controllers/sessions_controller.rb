class SessionsController < ApplicationController
  skip_before_action :require_sign_in, only: %i[new create]
  before_action :redirect_if_signed_in, only: %i[new create]

  def new
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)

    if user&.authenticate(params[:password].to_s)
      return_to = sign_in(user)
      redirect_to return_to || root_path, notice: "Signed in as #{user.name}."
    else
      flash.now[:alert] = "Incorrect email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to sign_in_path, notice: "You have signed out."
  end
end
