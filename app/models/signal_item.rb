# One row on the Signal Card: a need, how the resident shows it,
# and what a visitor should check. Named SignalItem because Signal
# is already a Ruby core module.
class SignalItem < ApplicationRecord
  belongs_to :resident
  has_many :care_concerns, dependent: :nullify

  validates :need, :shows_by, :check_for, presence: true

  # "check_for" is entered one item per line and shown as a checklist.
  def checklist
    check_for.to_s.split(/\r?\n/).map(&:strip).reject(&:blank?)
  end
end
