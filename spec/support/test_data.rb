# Test data helpers shared by RSpec and Cucumber. They follow the product story:
# Linda's son David opens a concern, staff say it's fixed, and her daughter Amy rechecks it.
module TestData
  PASSWORD = "password123".freeze

  def create_user(name: "Amy", email: nil)
    email ||= "#{name.downcase.gsub(/[^a-z0-9]+/, '.')}@example.com"
    User.create!(name: name, email: email, password: PASSWORD)
  end

  def user_named(name)
    User.find_by(name: name) || create_user(name: name)
  end

  def create_resident(name: "Linda Chen", **attrs)
    Resident.create!({ name: name, facility: "Greenview Nursing Home", room: "214" }.merge(attrs))
  end

  def add_member(resident, user, role: "relative")
    resident.memberships.find_or_create_by!(user: user) { |membership| membership.role = role }
  end

  def create_signal(resident, need: "Thirst", **attrs)
    resident.signal_items.create!(
      { need: need, shows_by: "Licks her lips", check_for: "Cup within reach\nCup half full" }.merge(attrs)
    )
  end

  def create_concern(resident, title: "Water cup out of reach", opened_by: nil, **attrs)
    opened_by ||= user_named("David")
    add_member(resident, opened_by)
    resident.care_concerns.create!(
      { title: title, fixed_goal: "Cup on her right side, half full", opened_by: opened_by }.merge(attrs)
    )
  end

  def report_fixed(concern, staff_name: "Maria R.", statement: "We moved the bed table",
                   said_on: Date.new(2026, 10, 14), recheck_assignee: nil, recorded_by: nil)
    add_member(concern.resident, recheck_assignee) if recheck_assignee
    concern.staff_responses.create!(
      staff_name: staff_name, statement: statement, said_on: said_on,
      recorded_by: recorded_by || concern.opened_by, recheck_assignee_id: recheck_assignee&.id
    )
  end

  # Pass at: to place the recheck on a given date, for meeting brief periods.
  def record_recheck(concern, result:, checked_by: nil, note: nil, at: nil)
    checked_by ||= user_named("Amy")
    add_member(concern.resident, checked_by)
    recheck = concern.rechecks.create!(checked_by: checked_by, result: result, note: note)
    recheck.update_columns(created_at: at, updated_at: at) if at
    recheck
  end

  def create_visit(resident, user: nil, mood: "okay", visited_on: Date.current, notes: nil, signal_items: [])
    user ||= user_named("Amy")
    add_member(resident, user)
    resident.visits.create!(user: user, mood: mood, visited_on: visited_on, notes: notes, signal_items: signal_items)
  end
end
