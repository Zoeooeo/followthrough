# One row on the Signal Card. Named SignalItem because Signal is a Ruby core module.
class SignalItem < ApplicationRecord
  belongs_to :resident
  belongs_to :updated_by, class_name: "User", optional: true
  has_many :care_concerns, dependent: :nullify
  has_and_belongs_to_many :visits

  validates :need, :shows_by, :check_for, presence: true

  def self.matching(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip.downcase)}%"
    where("LOWER(need) LIKE :pattern ESCAPE '\\' OR LOWER(shows_by) LIKE :pattern ESCAPE '\\' " \
          "OR LOWER(check_for) LIKE :pattern ESCAPE '\\'", pattern: pattern)
  end

  def checklist
    check_for.to_s.split(/\r?\n/).map(&:strip).compact_blank
  end
end
