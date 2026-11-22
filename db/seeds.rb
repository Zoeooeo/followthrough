# Sample data with three demo accounts (password: password123). Run with: bin/rails db:seed

DEMO_PASSWORD = "password123".freeze

def demo_user(name, email)
  User.find_or_create_by!(email: email) do |user|
    user.name = name
    user.password = DEMO_PASSWORD
  end
end

david = demo_user("David", "david@example.com")
amy = demo_user("Amy", "amy@example.com")
grace = demo_user("Grace", "grace@example.com")

linda = Resident.find_or_create_by!(name: "Linda Chen") do |r|
  r.facility = "Greenview Nursing Home"
  r.room = "214"
end

{ david => "organizer", amy => "relative", grace => "relative" }.each do |user, role|
  linda.memberships.find_or_create_by!(user: user) { |membership| membership.role = role }
end

thirst = linda.signal_items.find_or_create_by!(need: "Thirst") do |s|
  s.shows_by = "Licks her lips, points at her mouth, restless after meals"
  s.check_for = "Cup on her right side, within reach\nCup at least half full\nLips not dry or cracked"
  s.updated_by = david
end

linda.signal_items.find_or_create_by!(need: "Pain (left knee)") do |s|
  s.shows_by = "Rubs her left knee, grimaces when standing"
  s.check_for = "Pillow under her left knee in bed\nNo grimace when moved to the chair"
  s.updated_by = amy
end

unless linda.care_concerns.exists?
  visit = linda.visits.create!(
    user: david, visited_on: Date.current - 4, mood: "okay", signal_items: [thirst],
    notes: "Lips were dry. Her water cup was across the room on the windowsill."
  )

  cup = linda.care_concerns.create!(
    title: "Water cup out of reach",
    fixed_goal: "Cup with a lid on the right side of her bed table, at least half full, at every visit",
    opened_by: david, signal_item: thirst, visit: visit
  )
  cup.staff_responses.create!(
    staff_name: "Maria R., charge nurse", statement: "We moved the bed table to her right side and added it to the care plan.",
    said_on: Date.current - 2, recorded_by: david, recheck_assignee_id: amy.id
  )

  glasses = linda.care_concerns.create!(
    title: "Glasses not cleaned", fixed_goal: "Glasses clean and on her nightstand every morning", opened_by: grace
  )
  glasses.staff_responses.create!(
    staff_name: "Tom K., aide", statement: "We added it to the morning routine.",
    said_on: Date.current - 10, recorded_by: grace, recheck_assignee_id: amy.id
  )
  glasses.rechecks.create!(checked_by: amy, result: "verified", note: "Clean and on the nightstand")

  hearing = linda.care_concerns.create!(
    title: "Hearing aid not put in", fixed_goal: "Hearing aid in her left ear by 10 am", opened_by: amy
  )
  hearing.staff_responses.create!(
    staff_name: "Tom K., aide", statement: "It's on the morning checklist now.",
    said_on: Date.current - 8, recorded_by: amy, recheck_assignee_id: david.id
  )
  hearing.rechecks.create!(checked_by: david, result: "not_verified", note: "Not in at 11 am")

  linda.care_concerns.create!(
    title: "Room too cold at night", fixed_goal: "Window closed, cardigan on, extra blanket within reach", opened_by: amy
  )
end

puts "Seeded #{User.count} user(s), #{Resident.count} resident(s), #{SignalItem.count} signal(s), " \
     "#{Visit.count} visit(s), #{CareConcern.count} concern(s)."
