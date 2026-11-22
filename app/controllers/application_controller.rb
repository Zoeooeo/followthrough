class ApplicationController < ActionController::Base
  before_action :require_sign_in
  helper_method :current_user, :signed_in?

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = session[:user_id] && User.find_by(id: session[:user_id])
  end

  def signed_in?
    current_user.present?
  end

  # Returns the page the visitor wanted before signing in, if any.
  def sign_in(user)
    return_to = session[:return_to]
    reset_session
    session[:user_id] = user.id
    @current_user = user
    return_to
  end

  def sign_out
    reset_session
    @current_user = nil
  end

  def require_sign_in
    return if signed_in?

    session[:return_to] = request.fullpath if request.get?
    message = request.path == root_path ? nil : "Please sign in to continue."
    redirect_to sign_in_path, alert: message
  end

  def redirect_if_signed_in
    redirect_to root_path if signed_in?
  end

  # Only family members can see a resident. Everyone else gets the same page as a missing record.
  def set_resident
    @resident = current_user.residents.find(params[:resident_id])
  end

  def render_not_found
    render "shared/not_found", status: :not_found
  end
end
