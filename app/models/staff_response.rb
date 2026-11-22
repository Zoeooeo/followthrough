# What staff said about a concern. Saving it marks the concern Reported fixed
# and can assign the recheck to a relative other than the one who opened it.
class StaffResponse < ApplicationRecord
  belongs_to :care_concern
  belongs_to :recorded_by, class_name: "User"

  attribute :recheck_assignee_id, :integer

  validates :staff_name, :statement, :said_on, presence: true
  validate :concern_is_waiting_for_staff, :recheck_assignee_is_another_relative, on: :create

  after_create :mark_concern_reported_fixed

  def recheck_assignee
    return if recheck_assignee_id.blank? || care_concern.nil?

    care_concern.resident.members.find_by(id: recheck_assignee_id)
  end

  private

  def concern_is_waiting_for_staff
    return if care_concern.nil? || care_concern.awaiting_staff?

    errors.add(:base, "A staff response can't be added while the concern is #{care_concern.status_label}")
  end

  def recheck_assignee_is_another_relative
    return if recheck_assignee_id.blank? || care_concern.nil?

    assignee = recheck_assignee
    if assignee.nil?
      errors.add(:recheck_assignee_id, "must be in this resident's family")
    elsif assignee == care_concern.opened_by
      errors.add(:recheck_assignee_id, "must be someone other than the relative who opened the concern")
    end
  end

  def mark_concern_reported_fixed
    care_concern.update!(status: "reported_fixed", assigned_to: recheck_assignee)
  end
end
