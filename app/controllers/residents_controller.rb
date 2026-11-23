class ResidentsController < ApplicationController
  before_action :set_own_resident, only: %i[show edit update]
  before_action :require_organizer, only: %i[edit update]

  def show
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
    # A profile made while exploring the demo is part of the demo and is deleted with it.
    @resident = Resident.new(resident_params.merge(demo: current_user.demo?))
    @resident.memberships.build(user: current_user, role: "organizer")

    if @resident.save
      redirect_to @resident, notice: "Profile created for #{@resident.name}. You're the organizer, so you can invite relatives from the Family page."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  # Residents often move rooms, so the organizer can keep the name, facility and room up to date.
  def update
    if @resident.update(resident_params)
      redirect_to @resident, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_own_resident
    @resident = current_user.residents.find(params[:id])
  end

  def require_organizer
    return if @resident.organizer?(current_user)

    redirect_to resident_path(@resident), alert: "Only the organizer can edit this profile."
  end

  def resident_params
    params.require(:resident).permit(:name, :facility, :room)
  end
end
