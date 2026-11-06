require "rails_helper"

RSpec.describe "Concerns", type: :request do
  let(:resident) { create_resident }

  describe "GET index" do
    it "lists every concern with its status, including verified ones" do
      create_concern(resident, title: "Room too cold")
      done = create_concern(resident, title: "Glasses not cleaned")
      report_fixed(done)
      record_recheck(done, result: "verified")

      get resident_care_concerns_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Room too cold", "Glasses not cleaned", "Open", "Verified")
    end
  end

  describe "GET new" do
    it "offers the resident's signals" do
      create_signal(resident, need: "Thirst")

      get new_resident_care_concern_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Open a concern", "Related signal", "Thirst")
    end
  end

  describe "POST create" do
    let(:signal) { create_signal(resident) }
    let(:params) do
      {
        care_concern: {
          title: "Water cup out of reach", fixed_goal: "Cup within reach, half full",
          opened_by: "David", signal_item_id: signal.id
        }
      }
    end

    it "opens a concern linked to a signal" do
      expect {
        post resident_care_concerns_path(resident), params: params
      }.to change(CareConcern, :count).by(1)

      concern = CareConcern.last
      expect(concern).to be_status_open
      expect(concern.signal_item).to eq(signal)
      expect(response).to redirect_to(resident_care_concern_path(resident, concern))
    end

    it "shows errors when the goal is missing" do
      post resident_care_concerns_path(resident), params: { care_concern: { title: "Room too cold", opened_by: "Amy" } }

      expect(response).to have_http_status(422)
      expect(response.body).to include("What fixed looks like can&#39;t be blank")
    end

    it "ignores a status sent in the form" do
      post resident_care_concerns_path(resident), params: { care_concern: params[:care_concern].merge(status: "verified") }
      expect(CareConcern.last).to be_status_open
    end
  end

  describe "GET show" do
    let(:concern) { create_concern(resident, signal_item: create_signal(resident)) }

    it "shows only the staff form while the concern is Open" do
      get resident_care_concern_path(resident, concern)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Record what staff said")
      expect(response.body).not_to include("Record a recheck")
    end

    it "shows the recheck form with the Signal Card checklist after staff report a fix" do
      report_fixed(concern)

      get resident_care_concern_path(resident, concern)

      expect(response.body).to include("Record a recheck", "Check for (from the Signal Card)", "Cup within reach")
      expect(response.body).not_to include("Record what staff said")
    end

    it "returns 404 for a concern that belongs to another profile" do
      other = create_concern(create_resident(name: "Robert Lee"))
      get resident_care_concern_path(resident, other)
      expect(response).to have_http_status(:not_found)
    end
  end
end
