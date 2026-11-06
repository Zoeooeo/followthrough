# A problem the family noticed during a visit, tracked until a relative
# has seen it fixed.
#
# Status flow:
#
#   open ──staff response──> reported_fixed ──recheck──> verified
#                                  │                         │
#                                  └──recheck──> not_verified │
#                                                             └──recheck──> recurred
#
# A staff response can be recorded while the concern is open, not_verified
# or recurred, and always moves it to reported_fixed. "Reported fixed" is
# never treated as resolved: only a relative's recheck can verify it.
class CareConcern < ApplicationRecord
  STATUSES = %w[open reported_fixed verified not_verified recurred].freeze
  AWAITING_STAFF = %w[open not_verified recurred].freeze

  belongs_to :resident
  belongs_to :signal_item, optional: true
  has_many :staff_responses, dependent: :destroy
  has_many :rechecks, dependent: :destroy

  enum :status, STATUSES.index_with(&:itself), prefix: true, default: "open", validate: true

  validates :title, :fixed_goal, :opened_by, presence: true
  validate :signal_item_belongs_to_same_resident

  def status_label
    status.to_s.humanize
  end

  # Staff can be asked again whenever the family has not seen a fix.
  def awaiting_staff?
    AWAITING_STAFF.include?(status)
  end

  # Which recheck results make sense from the current status.
  def allowed_recheck_results
    case status
    when "reported_fixed" then %w[verified not_verified]
    when "verified" then %w[recurred]
    else []
    end
  end

  def recheck_allowed?
    allowed_recheck_results.any?
  end

  # Staff responses and family rechecks in the order they happened.
  def timeline
    (staff_responses.select(&:persisted?) + rechecks.select(&:persisted?)).sort_by(&:created_at)
  end

  private

  def signal_item_belongs_to_same_resident
    return if signal_item.nil? || signal_item.resident_id == resident_id

    errors.add(:signal_item, "must be on this resident's Signal Card")
  end
end
