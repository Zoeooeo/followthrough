require "rails_helper"

RSpec.describe "Visits", type: :request do
  let(:amy) { @amy }
  let(:resident) { @resident }
  let(:thirst) { @thirst }

  before do
    @amy, @resident = sign_in_to_family(name: "Amy")
    @thirst = create_signal(@resident, need: "Thirst")
  end

  describe "GET new" do
    it "shows the form with the Signal Card's signals" do
      get new_resident_visit_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Log a visit", "How was Linda Chen today?", "Thirst", "Save visit")
    end

    it "lists the rechecks assigned to me for this resident" do
      report_fixed(create_concern(resident, title: "Water cup out of reach"), recheck_assignee: amy)

      get new_resident_visit_path(resident)

      expect(response.body).to include("1 recheck for you on this visit", "Water cup out of reach")
    end
  end

  describe "POST create" do
    let(:params) do
      { visit: { visited_on: Date.current.to_s, mood: "okay", notes: "Ate most of lunch", signal_item_ids: ["", thirst.id] } }
    end

    it "saves the visit as the signed-in relative with the signals they noticed" do
      expect {
        post resident_visits_path(resident), params: params
      }.to change(Visit, :count).by(1)

      visit = Visit.last
      expect(visit.user).to eq(amy)
      expect(visit.signal_items).to eq([thirst])
      expect(response).to redirect_to(resident_visit_path(resident, visit))
      follow_redirect!
      expect(response.body).to include("Visit saved.", "Okay", "Thirst", "Ate most of lunch")
    end

    it "ignores signals from another family's Signal Card" do
      other_signal = create_signal(create_resident(name: "Robert Lee"), need: "Pain")

      post resident_visits_path(resident), params: { visit: params[:visit].merge(signal_item_ids: [other_signal.id]) }

      expect(Visit.last.signal_items).to be_empty
    end

    it "shows errors for a missing mood or a future date" do
      expect {
        post resident_visits_path(resident), params: { visit: { visited_on: (Date.current + 1).to_s, mood: "" } }
      }.not_to change(Visit, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Mood must be Good, Okay, or Not good", "Visit date can&#39;t be in the future")
    end
  end

  describe "viewing visits" do
    it "shows one visit and the concerns opened from it" do
      visit = create_visit(resident, user: amy, notes: "Window was open", signal_items: [thirst])
      create_concern(resident, title: "Room too cold", visit: visit)

      get resident_visit_path(resident, visit)

      expect(response.body).to include("Visited by Amy", "Thirst", "Window was open", "Room too cold",
                                       "Open a concern from this visit")
    end

    it "shows a visit with no signals or concerns" do
      visit = create_visit(resident, user: amy)

      get resident_visit_path(resident, visit)

      expect(response.body).to include("None", "No concerns opened from this visit.")
    end

    it "lists all visits, most recent first" do
      create_visit(resident, user: amy, visited_on: Date.new(2026, 11, 1))
      create_visit(resident, user: amy, visited_on: Date.new(2026, 11, 8), signal_items: [thirst])

      get resident_visits_path(resident)

      expect(response.body.index("November 8, 2026")).to be < response.body.index("November 1, 2026")
    end

    it "says when no visits are logged" do
      get resident_visits_path(resident)
      expect(response.body).to include("No visits logged yet.")
    end

    it "hides another family's visits" do
      other_visit = create_visit(create_resident(name: "Robert Lee"))
      get resident_visit_path(resident, other_visit)
      expect(response).to have_http_status(:not_found)
    end
  end
end
