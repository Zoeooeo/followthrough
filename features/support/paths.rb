module NavigationHelpers
  include Rails.application.routes.url_helpers

  def path_to(page_name)
    case page_name
    when /^the home page$/
      root_path
    when /^the sign in page$/
      sign_in_path
    when /^the sign up page$/
      sign_up_path
    when /^the join page$/
      join_path
    when /^the page for resident "(.*)"$/
      resident_path(Resident.find_by!(name: Regexp.last_match(1)))
    when /^the family page for "(.*)"$/
      resident_memberships_path(Resident.find_by!(name: Regexp.last_match(1)))
    when /^the meeting brief for "(.*)"$/
      resident_brief_path(Resident.find_by!(name: Regexp.last_match(1)))
    when /^the new visit page for "(.*)"$/
      new_resident_visit_path(Resident.find_by!(name: Regexp.last_match(1)))
    when /^the latest visit to "(.*)"$/
      resident = Resident.find_by!(name: Regexp.last_match(1))
      resident_visit_path(resident, resident.visits.order(:created_at).last)
    when /^the concern page for "(.*)"$/
      concern = CareConcern.find_by!(title: Regexp.last_match(1))
      resident_care_concern_path(concern.resident, concern)
    when /^all concerns for "(.*)"$/
      resident_care_concerns_path(Resident.find_by!(name: Regexp.last_match(1)))
    else
      raise "Can't find a path for \"#{page_name}\". Add it to features/support/paths.rb"
    end
  end
end

World(NavigationHelpers)
