require "rails_helper"

RSpec.describe "Residents", type: :request do
  describe "creating a profile" do
    let(:david) { create_user(name: "David") }

    before { sign_in_as(david) }

    it "shows the form" do
      get new_resident_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Create profile")
    end

    it "creates the profile and makes the creator its organizer" do
      expect {
        post residents_path, params: { resident: { name: "Linda Chen", facility: "Greenview Nursing Home", room: "214" } }
      }.to change(Resident, :count).by(1)

      resident = Resident.last
      expect(resident.organizer?(david)).to be(true)
      expect(response).to redirect_to(resident_path(resident))
      follow_redirect!
      expect(response.body).to include("Profile created for Linda Chen.", "Lives at Greenview Nursing Home, Room 214")
    end

    it "shows an error without a name and creates no membership" do
      expect {
        post residents_path, params: { resident: { name: "" } }
      }.not_to change(Membership, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Name can&#39;t be blank")
    end
  end

  describe "viewing a profile" do
    it "shows the Signal Card, open concerns, rechecks due and recent visits" do
      amy, resident = sign_in_to_family(name: "Amy")
      create_signal(resident, need: "Thirst", updated_by: amy)
      fixed = create_concern(resident, title: "Water cup out of reach")
      report_fixed(fixed, recheck_assignee: amy)
      create_visit(resident, user: amy, mood: "not_good")

      get resident_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        "Signal Card", "Thirst", "Updated by Amy", "Family observations, not medical judgment.",
        "Rechecks due", "Water cup out of reach", "Recheck assigned to you", "Recent visits", "Not good"
      )
    end

    it "says who the recheck is assigned to, or that anyone but the opener can do it" do
      _amy, resident = sign_in_to_family(name: "Amy")
      report_fixed(create_concern(resident, title: "Water cup out of reach"), recheck_assignee: user_named("Grace"))
      report_fixed(create_concern(resident, title: "Glasses not cleaned"))

      get resident_path(resident)

      expect(response.body).to include("Recheck assigned to Grace.", "Anyone except David can check it.")
    end

    it "shows empty states for a new profile" do
      _amy, resident = sign_in_to_family(name: "Amy")
      get resident_path(resident)
      expect(response.body).to include("No rechecks due right now.", "No open concerns.", "No signals yet.",
                                       "No visits logged yet.")
    end

    it "filters the Signal Card by a search" do
      _amy, resident = sign_in_to_family(name: "Amy")
      create_signal(resident, need: "Thirst")
      create_signal(resident, need: "Pain", shows_by: "Rubs her knee", check_for: "Pillow under knee")

      get resident_path(resident, q: "knee")

      expect(response.body).to include("<h3>Pain</h3>", "Show all signals")
      expect(response.body).not_to include("<h3>Thirst</h3>")
    end

    it "says when no signal matches" do
      _amy, resident = sign_in_to_family(name: "Amy")
      create_signal(resident, need: "Thirst")

      get resident_path(resident, q: "knee")

      expect(response.body).to include("No signals match \"knee\".")
    end

    it "is hidden from people outside the family" do
      resident = create_resident
      sign_in_as(create_user(name: "Grace"))

      get resident_path(resident)

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("We couldn't find that page.")
    end

    it "returns 404 for a profile that does not exist" do
      sign_in_as(create_user(name: "Amy"))
      get resident_path(id: 0)
      expect(response).to have_http_status(:not_found)
    end
  end
end
