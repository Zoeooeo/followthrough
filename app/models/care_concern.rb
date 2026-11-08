# open, not_verified, recurred -> reported_fixed (staff response)
# reported_fixed -> verified or not_verified (family recheck)
# verified -> recurred (family recheck)
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

  def awaiting_staff?
    AWAITING_STAFF.include?(status)
  end

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

  def timeline
    # Failed submissions leave unsaved entries in the associations.
    (staff_responses + rechecks).select(&:persisted?).sort_by(&:created_at)
  end

  private

  def signal_item_belongs_to_same_resident
    return if signal_item.nil? || signal_item.resident_id == resident_id

    errors.add(:signal_item, "must be on this resident's Signal Card")
  end
end
