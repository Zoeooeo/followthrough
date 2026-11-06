class StaffResponsesController < ApplicationController
  before_action :set_resident
  before_action :set_care_concern

  def create
    @staff_response = @care_concern.staff_responses.build(staff_response_params)

    if @staff_response.save
      redirect_to resident_care_concern_path(@resident, @care_concern),
                  notice: "Staff response saved. This concern is Reported fixed until a relative rechecks it."
    else
      @recheck = Recheck.new
      render "care_concerns/show", status: :unprocessable_entity
    end
  end

  private

  def set_care_concern
    @care_concern = @resident.care_concerns.find(params[:care_concern_id])
  end

  def staff_response_params
    params.require(:staff_response).permit(:staff_name, :statement, :said_on)
  end
end
