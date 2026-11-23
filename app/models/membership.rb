# Links a relative to a resident's private family space.
class Membership < ApplicationRecord
  ROLES = %w[organizer relative].freeze

  belongs_to :user
  belongs_to :resident

  enum :role, ROLES.index_with(&:itself), default: "relative", validate: true

  validates :user_id, uniqueness: { scope: :resident_id, message: "is already in this family" }

  # A removed relative can no longer see this family, so any recheck still waiting on them
  # is opened to the rest of the family instead of being left with no one to do it.
  # Skipped when the whole profile is being deleted.
  after_destroy :release_waiting_rechecks, unless: :destroyed_by_association

  def waiting_rechecks
    resident.care_concerns.status_reported_fixed.where(assigned_to: user)
  end

  def role_label
    role.to_s.humanize
  end

  private

  def release_waiting_rechecks
    waiting_rechecks.update_all(assigned_to_id: nil, updated_at: Time.current)
  end
end
