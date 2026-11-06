# The loved one living in a care facility. One shared profile per family.
class Resident < ApplicationRecord
  has_many :signal_items, dependent: :destroy
  has_many :care_concerns, dependent: :destroy

  validates :name, presence: true

  # Concerns the family still has to follow up on (everything except Verified).
  def unresolved_concerns
    care_concerns.where.not(status: "verified").order(:created_at)
  end

  # Concerns staff reported fixed that a relative has not checked yet.
  def rechecks_due
    care_concerns.status_reported_fixed.order(:updated_at)
  end

  def location
    [facility.presence, room.present? ? "Room #{room}" : nil].compact.join(" · ")
  end
end
