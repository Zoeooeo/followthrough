class StaffResponsesController < ApplicationController
  include CareConcernPage

  before_action :set_resident
  before_action :set_care_concern

  def create
    @staff_response = @care_concern.staff_responses.build(staff_response_params)
    @staff_response.recorded_by = current_user

    if @staff_response.save
      redirect_to resident_care_concern_path(@resident, @care_concern), notice: saved_message
    else
      prepare_care_concern_page
      render "care_concerns/show", status: :unprocessable_entity
    end
  end

  private

  def staff_response_params
    params.require(:staff_response).permit(:staff_name, :statement, :said_on, :recheck_assignee_id)
  end

  def saved_message
    message = "Staff response saved. This concern is Reported fixed until a relative rechecks it."
    assignee = @staff_response.recheck_assignee
    assignee ? "#{message} #{assignee.name} is assigned to recheck it." : message
  end
end
