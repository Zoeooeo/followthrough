class Recheck < ApplicationRecord
  RESULTS = %w[verified not_verified recurred].freeze

  belongs_to :care_concern

  validates :checked_by, presence: true
  validates :result, inclusion: { in: RESULTS, message: "must be Verified, Not verified, or Recurred" }
  validate :result_fits_concern_status, :checked_by_a_different_relative, on: :create

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

  # A different relative rechecks so follow-up doesn't depend on one person returning.
  def checked_by_a_different_relative
    return if care_concern.nil? || checked_by.blank?
    return unless checked_by.strip.casecmp?(care_concern.opened_by.to_s.strip)

    errors.add(:checked_by, "must be a different relative than #{care_concern.opened_by}, who opened this concern")
  end

  def update_concern_status
    care_concern.update!(status: result)
  end
end
