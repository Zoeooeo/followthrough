# Steps that set up data before a scenario.

def resident_named(name)
  Resident.find_by!(name: name)
end

def concern_titled(title)
  CareConcern.find_by!(title: title)
end

Given("a resident {string} exists") do |name|
  create_resident(name: name)
end

Given("{string} has a signal {string}") do |resident_name, need|
  create_signal(resident_named(resident_name), need: need)
end

Given("{string} has a concern {string} opened by {string}") do |resident_name, title, opener|
  create_concern(resident_named(resident_name), title: title, opened_by: opener)
end

Given("{string} has a concern {string} about {string} opened by {string}") do |resident_name, title, need, opener|
  resident = resident_named(resident_name)
  create_concern(resident, title: title, opened_by: opener, signal_item: resident.signal_items.find_by!(need: need))
end

Given("staff reported {string} as fixed") do |title|
  report_fixed(concern_titled(title))
end

Given("{string} verified {string}") do |relative, title|
  record_recheck(concern_titled(title), result: "verified", checked_by: relative)
end
