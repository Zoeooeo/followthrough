require "rails_helper"

RSpec.describe "Residents", type: :request do
  describe "GET /" do
    it "lists every profile" do
      create_resident(name: "Linda Chen")
      create_resident(name: "Robert Lee")

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Linda Chen", "Robert Lee", "Add a loved one")
    end

    it "says when there are no profiles yet" do
      get root_path
      expect(response.body).to include("No profiles yet.")
    end
  end

  describe "GET /residents/new" do
    it "shows the form" do
      get new_resident_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create profile")
    end
  end

  describe "POST /residents" do
    it "creates a profile and goes to it" do
      expect {
        post residents_path, params: { resident: { name: "Linda Chen", facility: "Greenview Nursing Home", room: "214" } }
      }.to change(Resident, :count).by(1)

      resident = Resident.last
      expect(response).to redirect_to(resident_path(resident))
      follow_redirect!
      expect(response.body).to include("Profile created for Linda Chen.", "Lives at Greenview Nursing Home, Room 214")
    end

    it "shows an error without a name" do
      expect {
        post residents_path, params: { resident: { name: "" } }
      }.not_to change(Resident, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "GET /residents/:id" do
    let(:resident) { create_resident }

    it "shows the Signal Card, open concerns and rechecks due" do
      create_signal(resident, need: "Thirst")
      fixed = create_concern(resident, title: "Water cup out of reach")
      report_fixed(fixed)

      get resident_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        "Signal Card", "Thirst", "Family observations, not medical judgment.",
        "Rechecks due", "Water cup out of reach", "Reported fixed"
      )
    end

    it "shows empty states for a new profile" do
      get resident_path(resident)
      expect(response.body).to include("No rechecks due right now.", "No open concerns.", "No signals yet.")
    end

    it "returns 404 for a profile that does not exist" do
      get resident_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
