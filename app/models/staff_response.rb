# What a staff member told the family about a concern. Saving one marks
# the concern "Reported fixed", which still needs a relative's recheck.
class StaffResponse < ApplicationRecord
  belongs_to :care_concern

  validates :staff_name, :statement, :said_on, presence: true
  validate :concern_is_waiting_for_staff, on: :create

  after_create :mark_concern_reported_fixed

  private

  def concern_is_waiting_for_staff
    return if care_concern.nil? || care_concern.awaiting_staff?

    errors.add(:base, "A staff response can't be added while the concern is #{care_concern.status_label}")
  end

  def mark_concern_reported_fixed
    care_concern.update!(status: "reported_fixed")
  end
end
