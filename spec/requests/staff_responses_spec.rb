require "rails_helper"

RSpec.describe "Staff responses", type: :request do
  let(:david) { @david }
  let(:resident) { @resident }
  let(:amy) { user_named("Amy") }
  let(:concern) { create_concern(resident, opened_by: david) }
  let(:valid_params) do
    { staff_response: { staff_name: "Maria R.", statement: "We moved the bed table", said_on: "2026-10-14",
                        recheck_assignee_id: amy.id } }
  end

  before do
    @david, @resident = sign_in_to_family(name: "David")
    add_member(resident, amy)
  end

  it "records what staff said, marks the concern Reported fixed, and assigns the recheck" do
    expect {
      post resident_care_concern_staff_responses_path(resident, concern), params: valid_params
    }.to change(StaffResponse, :count).by(1)

    expect(concern.reload).to be_status_reported_fixed
    expect(concern.assigned_to).to eq(amy)
    expect(StaffResponse.last.recorded_by).to eq(david)
    expect(response).to redirect_to(resident_care_concern_path(resident, concern))
    expect(flash[:notice]).to end_with("Amy is assigned to recheck it.")
    follow_redirect!
    expect(response.body).to include("Staff said", "Maria R.", "We moved the bed table", "October 14, 2026",
                                     "recorded by David")
  end

  it "can leave the recheck unassigned" do
    post resident_care_concern_staff_responses_path(resident, concern),
         params: { staff_response: valid_params[:staff_response].merge(recheck_assignee_id: "") }

    expect(concern.reload.assigned_to).to be_nil
    expect(flash[:notice]).to eq("Staff response saved. This concern is Reported fixed until a relative rechecks it.")
  end

  it "shows errors and keeps the concern Open when fields are missing" do
    post resident_care_concern_staff_responses_path(resident, concern),
         params: { staff_response: { statement: "", staff_name: "", said_on: "" } }

    expect(response).to have_http_status(422)
    expect(response.body).to include("Staff member can&#39;t be blank", "What they said can&#39;t be blank")
    expect(concern.reload).to be_status_open
  end

  it "will not assign the recheck to the relative who opened the concern" do
    post resident_care_concern_staff_responses_path(resident, concern),
         params: { staff_response: valid_params[:staff_response].merge(recheck_assignee_id: david.id) }

    expect(response).to have_http_status(422)
    expect(response.body).to include("Who should recheck must be someone other than the relative who opened the concern")
  end

  it "refuses a second staff response before anyone rechecks" do
    report_fixed(concern)

    expect {
      post resident_care_concern_staff_responses_path(resident, concern), params: valid_params
    }.not_to change(StaffResponse, :count)

    expect(response).to have_http_status(422)
    expect(response.body).to include("A staff response can&#39;t be added while the concern is Reported fixed")
  end

  it "is not available to people outside the family" do
    delete sign_out_path
    sign_in_as(user_named("Grace"))

    post resident_care_concern_staff_responses_path(resident, concern), params: valid_params

    expect(response).to have_http_status(:not_found)
    expect(concern.reload).to be_status_open
  end
end
