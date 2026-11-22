require "rails_helper"

RSpec.describe "Concerns", type: :request do
  let(:david) { @david }
  let(:resident) { @resident }

  before { @david, @resident = sign_in_to_family(name: "David") }

  describe "GET index" do
    it "lists every concern with who opened it and its status, including verified ones" do
      create_concern(resident, title: "Room too cold")
      done = create_concern(resident, title: "Glasses not cleaned")
      report_fixed(done)
      record_recheck(done, result: "verified")

      get resident_care_concerns_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Room too cold", "Glasses not cleaned", "David", "Open", "Verified")
    end
  end

  describe "GET new" do
    it "offers the resident's signals" do
      create_signal(resident, need: "Thirst")

      get new_resident_care_concern_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Open a concern", "Related signal", "Thirst")
    end

    it "links the concern to a visit when opened from one" do
      visit = create_visit(resident, user: david, visited_on: Date.new(2026, 11, 2))

      get new_resident_care_concern_path(resident, visit_id: visit.id)

      expect(response.body).to include("From your visit on November 2, 2026", "care_concern[visit_id]")
    end

    it "ignores a visit from another family" do
      other_visit = create_visit(create_resident(name: "Robert Lee"))

      get new_resident_care_concern_path(resident, visit_id: other_visit.id)

      expect(response.body).not_to include("From your visit on")
    end
  end

  describe "POST create" do
    let(:signal) { create_signal(resident) }
    let(:params) do
      { care_concern: { title: "Water cup out of reach", fixed_goal: "Cup within reach, half full", signal_item_id: signal.id } }
    end

    it "opens a concern as the signed-in relative, linked to a signal" do
      expect {
        post resident_care_concerns_path(resident), params: params
      }.to change(CareConcern, :count).by(1)

      concern = CareConcern.last
      expect(concern).to be_status_open
      expect(concern.opened_by).to eq(david)
      expect(concern.signal_item).to eq(signal)
      expect(response).to redirect_to(resident_care_concern_path(resident, concern))
    end

    it "records the visit it came from" do
      visit = create_visit(resident, user: david)
      post resident_care_concerns_path(resident), params: { care_concern: params[:care_concern].merge(visit_id: visit.id) }
      expect(CareConcern.last.visit).to eq(visit)
    end

    it "shows errors when the goal is missing" do
      post resident_care_concerns_path(resident), params: { care_concern: { title: "Room too cold" } }

      expect(response).to have_http_status(422)
      expect(response.body).to include("What fixed looks like can&#39;t be blank")
    end

    it "ignores a status or opener sent in the form" do
      grace = user_named("Grace")
      post resident_care_concerns_path(resident),
           params: { care_concern: params[:care_concern].merge(status: "verified", opened_by_id: grace.id) }

      expect(CareConcern.last).to be_status_open
      expect(CareConcern.last.opened_by).to eq(david)
    end
  end

  describe "GET show" do
    let(:amy) { user_named("Amy") }
    let(:concern) { create_concern(resident, opened_by: david, signal_item: create_signal(resident)) }

    before { add_member(resident, amy) }

    it "shows the staff form with the other relatives to pick from while the concern is Open" do
      get resident_care_concern_path(resident, concern)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Record what staff said", "Who should recheck", "Waiting for staff")
      amy_option = response.body[%r{<option[^>]*value="#{amy.id}"[^>]*>Amy</option>}] ||
                   response.body[%r{<option[^>]*selected[^>]*value="#{amy.id}"[^>]*>Amy</option>}]
      expect(amy_option).to include("selected")
      expect(response.body).not_to include("Record a recheck")
    end

    it "asks a family of one to invite another relative" do
      solo = create_resident(name: "Robert Lee")
      solo_concern = create_concern(solo, opened_by: david)

      get resident_care_concern_path(solo, solo_concern)

      expect(response.body).to include("David is the only one in this family", "Invite another relative")
      expect(response.body).not_to include("Who should recheck")
    end

    it "shows the recheck form with the Signal Card checklist to another relative" do
      report_fixed(concern, recheck_assignee: amy)
      delete sign_out_path
      sign_in_as(amy)

      get resident_care_concern_path(resident, concern)

      expect(response.body).to include("Record a recheck", "Check for (from the Signal Card)", "Cup within reach",
                                       "Recheck assigned to Amy", "Saved as checked by Amy")
      expect(response.body).not_to include("Record what staff said")
    end

    it "tells the relative who opened the concern that someone else must recheck it" do
      report_fixed(concern)

      get resident_care_concern_path(resident, concern)

      expect(response.body).to include("You opened this concern, so another relative needs to recheck it.")
      expect(response.body).not_to include("Record a recheck")
    end

    it "links back to the visit the concern came from" do
      visit = create_visit(resident, user: david, visited_on: Date.new(2026, 11, 2))
      from_visit = create_concern(resident, title: "Room too cold", opened_by: david, visit: visit)

      get resident_care_concern_path(resident, from_visit)

      expect(response.body).to include("Noticed during", "The visit on November 2, 2026")
    end

    it "returns 404 for a concern that belongs to another family" do
      other = create_concern(create_resident(name: "Robert Lee"))
      get resident_care_concern_path(resident, other)
      expect(response).to have_http_status(:not_found)
    end
  end
end
