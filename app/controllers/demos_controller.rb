# "Try a demo family" on the sign in page, for people who want to look around before signing up.
# Each visitor gets a guest account and their own copy of the sample family (see DemoFamily).
class DemosController < ApplicationController
  skip_before_action :require_sign_in, only: :create
  before_action :redirect_if_signed_in, only: :create

  def create
    sign_in(DemoFamily.create!)
    redirect_to root_path, notice: "Welcome! This demo family was made just for you, so nothing you do here is shared."
  end

  # "Leave the demo and sign up": deletes the demo (see sign_out) and opens the sign up page.
  def destroy
    return redirect_to(root_path) unless current_user.demo?

    sign_out
    redirect_to sign_up_path, notice: "The demo family was deleted. Create an account to start your own."
  end
end
