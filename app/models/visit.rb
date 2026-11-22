# One relative's visit: how the resident seemed, which signals they noticed, and notes.
class Visit < ApplicationRecord
  MOODS = %w[good okay not_good].freeze

  belongs_to :resident
  belongs_to :user
  has_many :care_concerns, dependent: :nullify
  has_and_belongs_to_many :signal_items

  validates :visited_on, presence: true
  validates :mood, inclusion: { in: MOODS, message: "must be Good, Okay, or Not good" }
  validate :not_in_the_future, :signals_from_this_resident
  validate :visitor_is_in_the_family, on: :create

  scope :recent_first, -> { order(visited_on: :desc, created_at: :desc) }

  def mood_label
    mood.to_s.humanize
  end

  private

  def not_in_the_future
    return if visited_on.nil? || visited_on <= Date.current

    errors.add(:visited_on, "can't be in the future")
  end

  def signals_from_this_resident
    return if signal_items.all? { |signal| signal.resident_id == resident_id }

    errors.add(:signal_items, "must be on this resident's Signal Card")
  end

  def visitor_is_in_the_family
    return if user.nil? || resident.nil? || resident.member?(user)

    errors.add(:user, "must be in this resident's family")
  end
end
