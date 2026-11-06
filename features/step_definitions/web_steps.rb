# Steps that drive the browser and check what is on the page.

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

When("I select {string} from {string}") do |option, field|
  select option, from: field
end

When("I follow {string} for the signal {string}") do |link, need|
  within("##{dom_id(SignalItem.find_by!(need: need))}") { click_link link }
end

When("I press {string} for the signal {string}") do |button, need|
  within("##{dom_id(SignalItem.find_by!(need: need))}") { click_button button }
end

Then("I should see {string}") do |text|
  expect(page).to have_content(text)
end

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then("the status should be {string}") do |status|
  expect(page).to have_css("#concern-status .badge", exact_text: status)
end

Then("{string} should be listed as {string}") do |title, status|
  within("##{dom_id(CareConcern.find_by!(title: title))}") do
    expect(page).to have_css(".badge", exact_text: status)
  end
end

Then("I should see {string} in the rechecks due") do |title|
  within("#rechecks-due") { expect(page).to have_content(title) }
end

Then("I should see {string} in the recheck checklist") do |item|
  within("#recheck-checklist") { expect(page).to have_content(item) }
end

Then("I should see the recheck form") do
  expect(page).to have_css("#recheck-form")
end

Then("I should not see the recheck form") do
  expect(page).not_to have_css("#recheck-form")
end

Then("I should see the staff response form") do
  expect(page).to have_css("#staff-response-form")
end

Then("I should not see the staff response form") do
  expect(page).not_to have_css("#staff-response-form")
end
