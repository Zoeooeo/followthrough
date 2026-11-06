# Named SignalItem because Signal is a Ruby core module.
class SignalItem < ApplicationRecord
  belongs_to :resident
  has_many :care_concerns, dependent: :nullify

  validates :need, :shows_by, :check_for, presence: true

  # check_for stores one checklist item per line.
  def checklist
    check_for.to_s.split(/\r?\n/).map(&:strip).compact_blank
  end
end
