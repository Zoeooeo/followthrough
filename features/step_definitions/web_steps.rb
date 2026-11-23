When(/^I (?:go to|am on) (.+)$/) do |page_name|
  visit path_to(page_name)
end

When("I follow {string}") do |link|
  click_link link
end

When("I press {string}") do |button|
  click_button button
end

When("I fill in {string} with {string}") do |field, value|
  fill_in field, with: value
end

When("I choose {string}") do |label|
  choose label
end

When("I check {string}") do |label|
  check label
end

When("I select {string} from {string}") do |option, field|
  select option, from: field
end

When("I follow {string} for the signal {string}") do |link, need|
  within("##{dom_id(SignalItem.find_by!(need: need))}") { click_link link }
end

When("I press {string} for the signal {string}") do |button, need|
  within("##{dom_id(SignalItem.find_by!(need: need))}") { click_button button }
end

When("I press {string} for the member {string}") do |button, name|
  membership = Membership.find_by!(user: User.find_by!(name: name))
  within("##{dom_id(membership)}") { click_button button }
end

When("I fill in the invite code for {string}") do |resident_name|
  fill_in "Invite code", with: resident_named(resident_name).invite_code.downcase
end

When("I start the recheck for {string}") do |title|
  within("##{dom_id(concern_titled(title), :my_recheck)}") { click_link "Log a visit" }
end

When("I mark {string} as {string}") do |title, choice|
  within("##{dom_id(concern_titled(title), :check)}") { choose choice }
end

When("I add the note {string} for {string}") do |note, title|
  within("##{dom_id(concern_titled(title), :check)}") { fill_in "Note", with: note }
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then("I should not see a {string} button") do |button|
  expect(page).not_to have_button(button)
end

Then("the status should be {string}") do |status|
  expect(page).to have_css("#concern-status .badge", exact_text: status)
end

Then("the progress should be at {string}") do |step|
  expect(page).to have_css("#concern-progress li.current", exact_text: step)
end

Then("{string} should be listed as {string}") do |title, status|
  within("##{dom_id(CareConcern.find_by!(title: title))}") do
    expect(page).to have_css(".badge", exact_text: status)
  end
end

Then("{string} should be listed as {string} in the family") do |name, role|
  membership = Membership.find_by!(user: User.find_by!(name: name))
  within("##{dom_id(membership)}") { expect(page).to have_css(".badge", exact_text: role) }
end

Then("I should see {string} in the rechecks due") do |title|
  within("#rechecks-due") { expect(page).to have_content(title) }
end

Then("I should see {string} in my rechecks") do |title|
  within("#my-rechecks") { expect(page).to have_content(title) }
end

Then("I should not see {string} in my rechecks") do |title|
  within("#my-rechecks") { expect(page).not_to have_content(title) }
end

Then("I should see {string} in the recheck checklist") do |item|
  expect(page).to have_css(".recheck-checklist li", text: item)
end

Then("I should see {string} in the recent visits") do |text|
  within("#recent-visits") { expect(page).to have_content(text) }
end

Then("I should see the signal {string}") do |need|
  expect(page).to have_css("#signal-card h3", exact_text: need)
end

Then("I should not see the signal {string}") do |need|
  expect(page).not_to have_css("#signal-card h3", exact_text: need)
end

Then("I should see the invite code for {string}") do |resident_name|
  expect(page).to have_css("#invite-code", exact_text: resident_named(resident_name).invite_code)
end

Then("{string} should not be an option for {string}") do |option, field|
  expect(page).to have_select(field)
  expect(page).not_to have_select(field, with_options: [option])
end

Then("the brief should show {int} reported fixed, {int} verified, and {int} not seen fixed") do |reported, verified, gap|
  expect(page).to have_css("#staff-reported-count .tile-number", exact_text: reported.to_s)
  expect(page).to have_css("#family-verified-count .tile-number", exact_text: verified.to_s)
  expect(page).to have_css("#not-seen-fixed-count .tile-number", exact_text: gap.to_s)
end

Then("the brief row for {string} should show {string}") do |title, text|
  within("##{dom_id(CareConcern.find_by!(title: title), :brief)}") { expect(page).to have_content(text) }
end

Then("I should see {string} in the visit checks") do |title|
  within("#visit-rechecks") { expect(page).to have_content(title) }
end

Then("I should not see {string} in the visit checks") do |title|
  expect(page).not_to have_css("##{dom_id(concern_titled(title), :check)}")
end

Then("I should be asked to check it on a visit") do
  expect(page).to have_css("#recheck-prompt")
end

Then("I should not be asked to check it on a visit") do
  expect(page).not_to have_css("#recheck-prompt")
end

Then("I should see the staff response form") do
  expect(page).to have_css("#staff-response-form")
end

Then("I should not see the staff response form") do
  expect(page).not_to have_css("#staff-response-form")
end
