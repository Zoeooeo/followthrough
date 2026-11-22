# open, not_verified, recurred -> reported_fixed (staff response)
# reported_fixed -> verified or not_verified (family recheck)
# verified -> recurred (family recheck)
class CareConcern < ApplicationRecord
  STATUSES = %w[open reported_fixed verified not_verified recurred].freeze
  AWAITING_STAFF = %w[open not_verified recurred].freeze
  PROGRESS_STEPS = ["Waiting for staff", "Reported fixed", "Verified"].freeze

  belongs_to :resident
  belongs_to :opened_by, class_name: "User"
  belongs_to :assigned_to, class_name: "User", optional: true
  belongs_to :signal_item, optional: true
  belongs_to :visit, optional: true
  has_many :staff_responses, dependent: :destroy
  has_many :rechecks, dependent: :destroy

  enum :status, STATUSES.index_with(&:itself), prefix: true, default: "open", validate: true

  validates :title, :fixed_goal, presence: true
  validate :signal_item_belongs_to_same_resident, :visit_belongs_to_same_resident
  validate :opener_is_in_the_family, on: :create
  validate :assignee_is_another_relative, if: :will_save_change_to_assigned_to_id?

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

  def progress_index
    case status
    when "reported_fixed" then 1
    when "verified" then 2
    else 0
    end
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

  def visit_belongs_to_same_resident
    return if visit.nil? || visit.resident_id == resident_id

    errors.add(:visit, "must be a visit to this resident")
  end

  def opener_is_in_the_family
    return if opened_by.nil? || resident.nil? || resident.member?(opened_by)

    errors.add(:opened_by, "must be in this resident's family")
  end

  def assignee_is_another_relative
    return if assigned_to.nil? || resident.nil?

    if assigned_to == opened_by
      errors.add(:assigned_to, "must be someone other than the relative who opened the concern")
    elsif !resident.member?(assigned_to)
      errors.add(:assigned_to, "must be in this resident's family")
    end
  end
end
