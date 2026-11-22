class ResidentsController < ApplicationController
  def show
    @resident = current_user.residents.find(params[:id])
    @query = params[:q].to_s.strip
    @signal_items = @resident.signal_items.matching(@query).includes(:updated_by).order(:created_at)
    @open_concerns = @resident.unresolved_concerns
    @rechecks_due = @resident.rechecks_due.includes(:opened_by, :assigned_to)
    @recent_visits = @resident.visits.recent_first.includes(:user).limit(3)
  end

  def new
    @resident = Resident.new
  end

  def create
    @resident = Resident.new(resident_params)
    @resident.memberships.build(user: current_user, role: "organizer")

    if @resident.save
      redirect_to @resident, notice: "Profile created for #{@resident.name}. You're the organizer, so you can invite relatives from the Family page."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def resident_params
    params.require(:resident).permit(:name, :facility, :room)
  end
end
