# The loved one in a care facility. Only members of the family space can see the profile.
class Resident < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :signal_items, dependent: :destroy
  has_many :care_concerns, dependent: :destroy
  has_many :visits, dependent: :destroy

  before_validation :assign_invite_code, on: :create

  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true

  def member?(user)
    user.present? && memberships.exists?(user_id: user.id)
  end

  def organizer?(user)
    user.present? && memberships.exists?(user_id: user.id, role: "organizer")
  end

  def members_other_than(user)
    members.where.not(id: user&.id).order(:name)
  end

  def unresolved_concerns
    care_concerns.where.not(status: "verified").order(:created_at)
  end

  def rechecks_due
    care_concerns.status_reported_fixed.order(:updated_at)
  end

  def location
    [facility.presence, room.present? ? "Room #{room}" : nil].compact.join(", ")
  end

  private

  def assign_invite_code
    self.invite_code ||= loop do
      code = SecureRandom.alphanumeric(8).upcase
      break code unless Resident.exists?(invite_code: code)
    end
  end
end
