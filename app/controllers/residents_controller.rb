class ResidentsController < ApplicationController
  def index
    @residents = Resident.order(:name)
  end

  def show
    @resident = Resident.find(params[:id])
    @signal_items = @resident.signal_items.order(:created_at)
    @open_concerns = @resident.unresolved_concerns
    @rechecks_due = @resident.rechecks_due
  end

  def new
    @resident = Resident.new
  end

  def create
    @resident = Resident.new(resident_params)

    if @resident.save
      redirect_to @resident, notice: "Profile created for #{@resident.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def resident_params
    params.require(:resident).permit(:name, :facility, :room)
  end
end
