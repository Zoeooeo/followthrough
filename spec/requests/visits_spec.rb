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

    it "has no recheck section when nothing is waiting" do
      get new_resident_visit_path(resident)
      expect(response.body).not_to include("Check fixes on this visit")
    end
  end

  describe "checking fixes on a visit" do
    let(:david) { user_named("David") }
    let!(:water) { create_concern(resident, title: "Water cup out of reach", opened_by: david, signal_item: thirst) }

    before { report_fixed(water, recheck_assignee: amy) }

    def post_visit(rechecks, mood: "okay")
      post resident_visits_path(resident),
           params: { visit: { visited_on: Date.current.to_s, mood: mood, rechecks: rechecks } }
    end

    it "lists my rechecks first, then other reported fixes, then verified ones, but never concerns I opened" do
      blanket = create_concern(resident, title: "Blanket missing", opened_by: david)
      report_fixed(blanket)
      glasses = create_concern(resident, title: "Glasses not cleaned", opened_by: david)
      report_fixed(glasses)
      record_recheck(glasses, result: "verified", checked_by: user_named("Grace"))
      report_fixed(create_concern(resident, title: "Room too cold", opened_by: amy))

      get new_resident_visit_path(resident)

      body = response.body
      expect(body).to include("Check fixes on this visit", "1 recheck for you on this visit", "assigned to you",
                              "Cup within reach", "Fixed", "Still not fixed", "Didn&#39;t check",
                              "Already verified", "It came back")
      expect(body.index("Water cup out of reach")).to be < body.index("Blanket missing")
      expect(body.index("Blanket missing")).to be < body.index("Glasses not cleaned")
      expect(body).not_to include("Room too cold")
    end

    it "saves the visit and the recheck together" do
      expect {
        post_visit({ water.id => { result: "verified", note: "Cup on the right, half full" } })
      }.to change(Visit, :count).by(1).and change(Recheck, :count).by(1)

      recheck = Recheck.last
      expect(recheck.checked_by).to eq(amy)
      expect(recheck.visit).to eq(Visit.last)
      expect(water.reload).to be_status_verified
      expect(flash[:notice]).to eq("Visit saved with 1 recheck.")
      follow_redirect!
      expect(response.body).to include("Fixes checked on this visit", "Water cup out of reach",
                                       "Fixed. Cup on the right, half full")

      get resident_care_concern_path(resident, water)
      expect(response.body).to include("Family saw · Amy", "during the visit on")
    end

    it "records that a fix did not hold" do
      post_visit({ water.id => { result: "not_verified" } })

      expect(water.reload).to be_status_not_verified
      follow_redirect!
      expect(response.body).to include("Still not fixed")
    end

    it "records nothing for a fix the visitor didn't check" do
      expect {
        post_visit({ water.id => { result: "", note: "" } })
      }.to change(Visit, :count).by(1).and change(Recheck, :count).by(0)

      expect(water.reload).to be_status_reported_fixed
      expect(flash[:notice]).to eq("Visit saved.")
    end

    it "reopens a verified concern as Recurred" do
      record_recheck(water, result: "verified", checked_by: user_named("Grace"))

      post_visit({ water.id => { result: "recurred" } })

      expect(water.reload).to be_status_recurred
    end

    it "keeps nothing when a recheck is not allowed, and names the concern in the error" do
      own = create_concern(resident, title: "Room too cold", opened_by: amy)
      report_fixed(own)

      expect {
        post_visit({ water.id => { result: "verified" }, own.id => { result: "verified" } })
      }.not_to change(Recheck, :count)

      expect(Visit.count).to eq(0)
      expect(response).to have_http_status(422)
      expect(response.body).to include(
        "Room too cold: Checked by must be a different relative than Amy, who opened this concern"
      )
      expect(water.reload).to be_status_reported_fixed
      expect(response.body).to include(%(id="visit_rechecks_#{water.id}_result_verified" value="verified" checked="checked"))
    end

    it "rejects a result that doesn't fit the concern's status" do
      post_visit({ water.id => { result: "recurred" } })

      expect(response).to have_http_status(422)
      expect(response.body).to include("Water cup out of reach: Recurred can&#39;t be recorded while the concern is Reported fixed")
    end

    it "does not record a recheck when the visit itself is invalid" do
      expect {
        post_visit({ water.id => { result: "verified", note: "Looks good" } }, mood: "")
      }.not_to change(Recheck, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Mood must be Good, Okay, or Not good", "Looks good")
      expect(water.reload).to be_status_reported_fixed
    end

    it "ignores concerns from another family and badly formed choices" do
      other = create_concern(create_resident(name: "Robert Lee"), opened_by: david)
      report_fixed(other)

      expect {
        post_visit({ other.id => { result: "verified" }, water.id => "verified" })
      }.to change(Visit, :count).by(1).and change(Recheck, :count).by(0)

      expect(other.reload).to be_status_reported_fixed
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
