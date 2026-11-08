# Small builders shared by RSpec and Cucumber so test setup reads like the
# product story: Linda's son David opens a concern, staff say it's fixed,
# and her daughter Amy rechecks it.
module TestData
  def create_resident(name: "Linda Chen", **attrs)
    Resident.create!({ name: name, facility: "Greenview Nursing Home", room: "214" }.merge(attrs))
  end

  def create_signal(resident, need: "Thirst", **attrs)
    resident.signal_items.create!(
      { need: need, shows_by: "Licks her lips", check_for: "Cup within reach\nCup half full" }.merge(attrs)
    )
  end

  def create_concern(resident, title: "Water cup out of reach", **attrs)
    resident.care_concerns.create!(
      { title: title, fixed_goal: "Cup on her right side, half full", opened_by: "David" }.merge(attrs)
    )
  end

  def report_fixed(concern, staff_name: "Maria R.", statement: "We moved the bed table")
    concern.staff_responses.create!(staff_name: staff_name, statement: statement, said_on: Date.new(2026, 10, 14))
  end

  def record_recheck(concern, result:, checked_by: "Amy", note: nil)
    concern.rechecks.create!(checked_by: checked_by, result: result, note: note)
  end
end
