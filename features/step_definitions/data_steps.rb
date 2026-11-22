def resident_named(name)
  Resident.find_by!(name: name)
end

def concern_titled(title)
  CareConcern.find_by!(title: title)
end

def noon_on(date_string)
  Date.iso8601(date_string).in_time_zone.change(hour: 12)
end

Given("a user {string} exists") do |name|
  user_named(name)
end

Given("I am signed in as {string}") do |name|
  @me = user_named(name)
  visit sign_in_path
  fill_in "Email", with: @me.email
  fill_in "Password", with: TestData::PASSWORD
  click_button "Sign in"
end

Given("a resident {string} exists") do |name|
  create_resident(name: name)
end

Given("I am in the family of {string}") do |resident_name|
  add_member(resident_named(resident_name), @me)
end

Given("{string} is in the family of {string}") do |user_name, resident_name|
  add_member(resident_named(resident_name), user_named(user_name))
end

Given("{string} is the organizer for {string}") do |user_name, resident_name|
  add_member(resident_named(resident_name), user_named(user_name), role: "organizer")
end

Given("{string} has a signal {string}") do |resident_name, need|
  create_signal(resident_named(resident_name), need: need)
end

Given("{string} has a concern {string} opened by {string}") do |resident_name, title, opener|
  create_concern(resident_named(resident_name), title: title, opened_by: user_named(opener))
end

Given("{string} has a concern {string} about {string} opened by {string}") do |resident_name, title, need, opener|
  resident = resident_named(resident_name)
  create_concern(resident, title: title, opened_by: user_named(opener),
                           signal_item: resident.signal_items.find_by!(need: need))
end

Given("staff reported {string} as fixed") do |title|
  report_fixed(concern_titled(title))
end

Given("staff reported {string} as fixed on {string}") do |title, date|
  report_fixed(concern_titled(title), said_on: Date.iso8601(date))
end

Given("staff reported {string} as fixed and assigned the recheck to {string}") do |title, name|
  report_fixed(concern_titled(title), recheck_assignee: user_named(name))
end

Given("{string} verified {string}") do |relative, title|
  record_recheck(concern_titled(title), result: "verified", checked_by: user_named(relative))
end

Given("{string} verified {string} on {string}") do |relative, title, date|
  record_recheck(concern_titled(title), result: "verified", checked_by: user_named(relative), at: noon_on(date))
end

Given("{string} marked {string} as not verified on {string}") do |relative, title, date|
  record_recheck(concern_titled(title), result: "not_verified", checked_by: user_named(relative),
                                        note: "Cup on the windowsill", at: noon_on(date))
end

Given("{string} logged a visit to {string}") do |name, resident_name|
  create_visit(resident_named(resident_name), user: user_named(name), mood: "good", notes: "Calm and chatty today")
end
