require "rails_helper"

RSpec.describe "Staff responses", type: :request do
  let(:resident) { create_resident }
  let(:concern) { create_concern(resident) }
  let(:valid_params) do
    { staff_response: { staff_name: "Maria R.", statement: "We moved the bed table", said_on: "2026-10-14" } }
  end

  it "records what staff said and marks the concern Reported fixed" do
    expect {
      post resident_care_concern_staff_responses_path(resident, concern), params: valid_params
    }.to change(StaffResponse, :count).by(1)

    expect(concern.reload).to be_status_reported_fixed
    expect(response).to redirect_to(resident_care_concern_path(resident, concern))
    follow_redirect!
    expect(response.body).to include("Staff said", "Maria R.", "We moved the bed table", "October 14, 2026")
  end

  it "shows errors and keeps the concern Open when fields are missing" do
    post resident_care_concern_staff_responses_path(resident, concern),
         params: { staff_response: { statement: "", staff_name: "", said_on: "" } }

    expect(response).to have_http_status(422)
    expect(response.body).to include("Staff member can&#39;t be blank", "What they said can&#39;t be blank")
    expect(concern.reload).to be_status_open
  end

  it "refuses a second staff response before anyone rechecks" do
    report_fixed(concern)

    expect {
      post resident_care_concern_staff_responses_path(resident, concern), params: valid_params
    }.not_to change(StaffResponse, :count)

    expect(response).to have_http_status(422)
    expect(response.body).to include("A staff response can&#39;t be added while the concern is Reported fixed")
  end
end
