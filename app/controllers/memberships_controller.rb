class MembershipsController < ApplicationController
  before_action :set_resident, only: %i[index destroy]

  def index
    @memberships = @resident.memberships.includes(:user).sort_by { |m| [m.organizer? ? 0 : 1, m.user.name] }
    @organizer = @resident.organizer?(current_user)
  end

  def new
  end

  def create
    code = params[:invite_code].to_s.strip.upcase
    resident = Resident.find_by(invite_code: code) if code.present?

    if resident.nil?
      flash.now[:alert] = "That invite code doesn't match any family."
      render :new, status: :unprocessable_entity
    elsif resident.member?(current_user)
      redirect_to resident_path(resident), notice: "You're already in #{resident.name}'s family."
    else
      resident.memberships.create!(user: current_user, role: "relative")
      redirect_to resident_path(resident), notice: "You joined #{resident.name}'s family."
    end
  end

  def destroy
    membership = @resident.memberships.find(params[:id])

    if !@resident.organizer?(current_user)
      redirect_to resident_memberships_path(@resident), alert: "Only the organizer can remove relatives."
    elsif membership.organizer?
      redirect_to resident_memberships_path(@resident), alert: "The organizer can't be removed."
    else
      had_rechecks = membership.waiting_rechecks.exists?
      membership.destroy
      redirect_to resident_memberships_path(@resident), notice: removed_message(membership.user.name, had_rechecks)
    end
  end

  private

  def removed_message(name, had_rechecks)
    message = "#{name} was removed from the family."
    had_rechecks ? "#{message} Rechecks assigned to #{name} are now open to the rest of the family." : message
  end
end
