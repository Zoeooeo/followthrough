# Sample data for local development and the Heroku demo.
# Run with: bin/rails db:seed (safe to run more than once)

linda = Resident.find_or_create_by!(name: "Linda Chen") do |r|
  r.facility = "Maple Grove"
  r.room = "214"
end

thirst = linda.signal_items.find_or_create_by!(need: "Thirst") do |s|
  s.shows_by = "Licks her lips, points at her mouth, restless after meals"
  s.check_for = "Cup on her right side, within reach\nCup at least half full\nLips not dry or cracked"
end

linda.signal_items.find_or_create_by!(need: "Pain (left knee)") do |s|
  s.shows_by = "Rubs her left knee, grimaces when standing"
  s.check_for = "Pillow under her left knee in bed\nNo grimace when moved to the chair"
end

unless linda.care_concerns.exists?(title: "Water cup out of reach")
  cup = linda.care_concerns.create!(
    title: "Water cup out of reach",
    fixed_goal: "Cup with a lid on the right side of her bed table, at least half full, at every visit",
    opened_by: "David",
    signal_item: thirst
  )
  cup.staff_responses.create!(
    staff_name: "Maria R., charge nurse",
    statement: "We moved the bed table to her right side and added it to the care plan.",
    said_on: Date.current - 2
  )
end

unless linda.care_concerns.exists?(title: "Room too cold at night")
  linda.care_concerns.create!(
    title: "Room too cold at night",
    fixed_goal: "Window closed, cardigan on, extra blanket within reach",
    opened_by: "Amy"
  )
end

puts "Seeded #{Resident.count} resident(s), #{SignalItem.count} signal(s), #{CareConcern.count} concern(s)."
