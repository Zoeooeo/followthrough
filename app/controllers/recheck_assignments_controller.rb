# Lets any relative in the family hand a waiting recheck to someone else,
# for example when the assigned relative can't visit soon.
class RecheckAssignmentsController < ApplicationController
  include CareConcernPage

  before_action :set_resident
  before_action :set_care_concern

  def update
    # Only a concern that staff reported fixed has a recheck waiting.
    unless @care_concern.status_reported_fixed?
      return redirect_to resident_care_concern_path(@resident, @care_concern),
                         alert: "Only a concern that staff reported fixed has a recheck to reassign."
    end

    # A blank choice clears the assignment so anyone except the opener can recheck.
    if @care_concern.update(assigned_to_id: assignment_params[:assigned_to_id].presence)
      redirect_to resident_care_concern_path(@resident, @care_concern), notice: reassigned_message
    else
      # Keep the rejected choice for its error message and show the saved assignment again.
      @failed_assignment = @care_concern
      @care_concern = @resident.care_concerns.find(@care_concern.id)
      prepare_care_concern_page
      render "care_concerns/show", status: :unprocessable_entity
    end
  end

  private

  def assignment_params
    params.require(:care_concern).permit(:assigned_to_id)
  end

  def reassigned_message
    assignee = @care_concern.assigned_to
    return "Recheck reassigned to #{assignee.name}." if assignee

    "Recheck is no longer assigned. Anyone except #{@care_concern.opened_by.name} can check it."
  end
end
