# A relative who signs in. Families are shared through memberships.
class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :residents, through: :memberships

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true

  # Rechecks staff reported fixed and assigned to this user, in families they still belong to.
  def assigned_rechecks
    CareConcern.status_reported_fixed
               .where(assigned_to: self, resident_id: residents.select(:id))
               .includes(:resident, :opened_by)
               .order(:updated_at)
  end

  def open_concerns
    CareConcern.where(resident_id: residents.select(:id))
               .where.not(status: "verified")
               .includes(:resident, :assigned_to)
               .order(:created_at)
  end
end
