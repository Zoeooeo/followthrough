# Shared setup for the concern page, which the staff response and recheck
# forms re-render when a submission has errors.
module CareConcernPage
  private

  def set_care_concern
    @care_concern = @resident.care_concerns.find(params[:care_concern_id] || params[:id])
  end

  def prepare_care_concern_page
    @assignee_options = @resident.members_other_than(@care_concern.opened_by).to_a
    @staff_response ||= StaffResponse.new(said_on: Date.current, recheck_assignee_id: @assignee_options.first&.id)
    @recheck ||= Recheck.new
  end
end
