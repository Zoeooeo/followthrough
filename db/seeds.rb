# Sample data with three demo accounts (password: password123). Run with: bin/rails db:seed

# Local variables instead of a constant and a method, so the file can be loaded again
# (for example by spec/db/seeds_spec.rb) without warnings.
demo_password = "password123"
demo_user = lambda do |name, email|
  User.find_or_create_by!(email: email) do |user|
    user.name = name
    user.password = demo_password
  end
end

david = demo_user.call("David", "david@example.com")
amy = demo_user.call("Amy", "amy@example.com")
grace = demo_user.call("Grace", "grace@example.com")

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
