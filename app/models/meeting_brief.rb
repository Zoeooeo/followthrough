# One-page summary for a care plan meeting: what staff reported fixed in a
# period, and what the family actually saw when they rechecked.
class MeetingBrief
  OUTCOME_LABELS = {
    "verified" => "Verified",
    "not_verified" => "Not verified",
    "recurred" => "Recurred",
    "waiting" => "Waiting for a recheck"
  }.freeze

  Row = Struct.new(:concern, :staff_responses, :rechecks, keyword_init: true) do
    def reported_fixed?
      staff_responses.any?
    end

    # The latest family recheck in the period decides the outcome.
    def outcome
      rechecks.any? ? rechecks.last.result : "waiting"
    end

    def outcome_label
      OUTCOME_LABELS.fetch(outcome)
    end
  end

  DEFAULT_DAYS = 30

  attr_reader :resident, :from, :to

  def initialize(resident, from: nil, to: nil)
    @resident = resident
    @to = to || Date.current
    @from = from || (@to - (DEFAULT_DAYS - 1))
    @from, @to = @to, @from if @from > @to
  end

  def rows
    @rows ||= begin
      ids = (staff_by_concern.keys + rechecks_by_concern.keys).uniq
      resident.care_concerns.where(id: ids).to_a
              .map { |concern| build_row(concern) }
              .sort_by { |row| [row.outcome == "verified" ? 1 : 0, row.concern.title] }
    end
  end

  def staff_reported_fixed_count
    reported_rows.size
  end

  def family_verified_count
    reported_rows.count { |row| row.outcome == "verified" }
  end

  def not_seen_fixed_count
    staff_reported_fixed_count - family_verified_count
  end

  # Why the gap exists, e.g. { "Not verified" => 1, "Waiting for a recheck" => 2 }.
  def gap_breakdown
    reported_rows.reject { |row| row.outcome == "verified" }
                 .group_by(&:outcome_label)
                 .transform_values(&:size)
  end

  private

  def reported_rows
    rows.select(&:reported_fixed?)
  end

  def build_row(concern)
    Row.new(concern: concern,
            staff_responses: staff_by_concern.fetch(concern.id, []),
            rechecks: rechecks_by_concern.fetch(concern.id, []))
  end

  def staff_by_concern
    @staff_by_concern ||= StaffResponse.joins(:care_concern)
                                       .where(care_concerns: { resident_id: resident.id }, said_on: from..to)
                                       .order(:said_on, :created_at)
                                       .group_by(&:care_concern_id)
  end

  def rechecks_by_concern
    period = from.in_time_zone.beginning_of_day..to.in_time_zone.end_of_day
    @rechecks_by_concern ||= Recheck.joins(:care_concern)
                                    .includes(:checked_by)
                                    .where(care_concerns: { resident_id: resident.id }, created_at: period)
                                    .order(:created_at)
                                    .group_by(&:care_concern_id)
  end
end
