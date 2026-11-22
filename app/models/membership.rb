# Links a relative to a resident's private family space.
class Membership < ApplicationRecord
  ROLES = %w[organizer relative].freeze

  belongs_to :user
  belongs_to :resident

  enum :role, ROLES.index_with(&:itself), default: "relative", validate: true

  validates :user_id, uniqueness: { scope: :resident_id, message: "is already in this family" }

  def role_label
    role.to_s.humanize
  end
end
