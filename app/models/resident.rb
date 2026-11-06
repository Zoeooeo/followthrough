class Resident < ApplicationRecord
  has_many :signal_items, dependent: :destroy
  has_many :care_concerns, dependent: :destroy

  validates :name, presence: true

  def unresolved_concerns
    care_concerns.where.not(status: "verified").order(:created_at)
  end

  def rechecks_due
    care_concerns.status_reported_fixed.order(:updated_at)
  end

  def location
    [facility.presence, room.present? ? "Room #{room}" : nil].compact.join(" · ")
  end
end
