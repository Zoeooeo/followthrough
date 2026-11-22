class VisitsController < ApplicationController
  before_action :set_resident

  def index
    @visits = @resident.visits.recent_first.includes(:user, :signal_items)
  end

  def show
    @visit = @resident.visits.find(params[:id])
  end

  def new
    @visit = Visit.new(resident: @resident, visited_on: Date.current)
    load_my_rechecks
  end

  def create
    @visit = @resident.visits.build(visit_params)
    @visit.user = current_user
    @visit.signal_items = @resident.signal_items.where(id: signal_item_ids)

    if @visit.save
      redirect_to resident_visit_path(@resident, @visit), notice: "Visit saved."
    else
      load_my_rechecks
      render :new, status: :unprocessable_entity
    end
  end

  private

  def visit_params
    params.require(:visit).permit(:visited_on, :mood, :notes)
  end

  def signal_item_ids
    Array(params.dig(:visit, :signal_item_ids)).compact_blank
  end

  def load_my_rechecks
    @my_rechecks = @resident.rechecks_due.where(assigned_to: current_user)
  end
end
