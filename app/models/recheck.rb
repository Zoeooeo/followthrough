# A relative's check on a later visit. It must be someone in the family
# other than the relative who opened the concern.
class Recheck < ApplicationRecord
  RESULTS = %w[verified not_verified recurred].freeze

  belongs_to :care_concern
  belongs_to :checked_by, class_name: "User"

  validates :result, inclusion: { in: RESULTS, message: "must be Verified, Not verified, or Recurred" }
  validate :result_fits_concern_status, :checked_by_another_relative, on: :create

  after_create :update_concern_status

  def result_label
    result.to_s.humanize
  end

  private

  def result_fits_concern_status
    return if care_concern.nil? || !RESULTS.include?(result)
    return if care_concern.allowed_recheck_results.include?(result)

    errors.add(:base, "#{result_label} can't be recorded while the concern is #{care_concern.status_label}")
  end

  def checked_by_another_relative
    return if care_concern.nil? || checked_by.nil?

    if checked_by == care_concern.opened_by
      errors.add(:checked_by, "must be a different relative than #{care_concern.opened_by.name}, who opened this concern")
    elsif !care_concern.resident.member?(checked_by)
      errors.add(:checked_by, "must be in this resident's family")
    end
  end

  def update_concern_status
    care_concern.update!(status: result)
  end
end
