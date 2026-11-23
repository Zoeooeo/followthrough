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

linda = Resident.find_or_create_by!(name: "Linda Chen", demo: false) do |r|
  r.facility = "Greenview Nursing Home"
  r.room = "214"
end

{ david => "organizer", amy => "relative", grace => "relative" }.each do |user, role|
  linda.memberships.find_or_create_by!(user: user) { |membership| membership.role = role }
end

# The same sample story that "Try a demo family" copies for each guest.
DemoFamily.populate(linda, david: david, amy: amy, grace: grace) unless linda.care_concerns.exists?

puts "Seeded #{User.count} user(s), #{Resident.count} resident(s), #{SignalItem.count} signal(s), " \
     "#{Visit.count} visit(s), #{CareConcern.count} concern(s)."
