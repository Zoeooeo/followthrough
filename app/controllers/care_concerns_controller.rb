class CareConcernsController < ApplicationController
  include CareConcernPage

  before_action :set_resident
  before_action :set_care_concern, only: :show

  def index
    @care_concerns = @resident.care_concerns.includes(:opened_by).order(created_at: :desc)
  end

  def show
    prepare_care_concern_page
  end

  def new
    @care_concern = CareConcern.new(resident: @resident, visit: @resident.visits.find_by(id: params[:visit_id]))
  end

  def create
    @care_concern = @resident.care_concerns.build(care_concern_params)
    @care_concern.opened_by = current_user

    if @care_concern.save
      redirect_to resident_care_concern_path(@resident, @care_concern), notice: "Concern opened."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def care_concern_params
    params.require(:care_concern).permit(:title, :fixed_goal, :signal_item_id, :visit_id)
  end
end
