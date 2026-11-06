class CareConcernsController < ApplicationController
  before_action :set_resident

  def index
    @care_concerns = @resident.care_concerns.order(created_at: :desc)
  end

  def show
    @care_concern = @resident.care_concerns.find(params[:id])
    @staff_response = StaffResponse.new(said_on: Date.current)
    @recheck = Recheck.new
  end

  def new
    @care_concern = CareConcern.new(resident: @resident)
  end

  def create
    @care_concern = @resident.care_concerns.build(care_concern_params)

    if @care_concern.save
      redirect_to resident_care_concern_path(@resident, @care_concern), notice: "Concern opened."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def care_concern_params
    params.require(:care_concern).permit(:title, :fixed_goal, :opened_by, :signal_item_id)
  end
end
