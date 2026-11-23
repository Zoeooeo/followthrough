require "rails_helper"

RSpec.describe "Home page", type: :request do
  it "shows the rechecks assigned to me first, then every open concern and my family spaces" do
    amy, linda = sign_in_to_family(name: "Amy")
    cup = create_concern(linda, title: "Water cup out of reach")
    report_fixed(cup, recheck_assignee: amy)
    create_concern(linda, title: "Room too cold")

    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Your rechecks", "Log a visit", "Water cup out of reach", "Room too cold",
                                     "Recheck: You", "Linda Chen")
  end

  it "names who else is assigned a recheck" do
    _amy, linda = sign_in_to_family(name: "Amy")
    report_fixed(create_concern(linda), recheck_assignee: user_named("Grace"))

    get root_path

    expect(response.body).to include("Recheck: Grace", "No rechecks assigned to you right now.")
  end

  it "guides someone who is not in a family yet" do
    sign_in_as(create_user(name: "Amy"))

    get root_path

    expect(response.body).to include("You're not in a family space yet.", "No open concerns.",
                                     "Add a loved one", "Join with an invite code")
  end

  it "does not show other families' concerns" do
    sign_in_to_family(name: "Amy")
    create_concern(create_resident(name: "Robert Lee"), title: "Hearing aid not put in")

    get root_path

    expect(response.body).not_to include("Hearing aid not put in", "Robert Lee")
  end
end
