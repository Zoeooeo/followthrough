require "rails_helper"

RSpec.describe "Reassigning a recheck", type: :request do
  let(:amy) { @amy }
  let(:resident) { @resident }
  let(:david) { user_named("David") }
  let(:grace) { user_named("Grace") }
  let(:concern) { create_concern(resident, opened_by: david) }

  before do
    @amy, @resident = sign_in_to_family(name: "Amy")
    add_member(resident, grace)
  end

  def reassign(to)
    patch resident_care_concern_recheck_assignment_path(resident, concern),
          params: { care_concern: { assigned_to_id: to } }
  end

  context "when staff reported the concern fixed" do
    before { report_fixed(concern, recheck_assignee: amy) }

    it "hands the recheck to another relative" do
      reassign(grace.id)

      expect(concern.reload.assigned_to).to eq(grace)
      expect(response).to redirect_to(resident_care_concern_path(resident, concern))
      expect(flash[:notice]).to eq("Recheck reassigned to Grace.")
      follow_redirect!
      expect(response.body).to include("Recheck assigned to Grace", "Reassign recheck")
    end

    it "clears the assignment when no one is chosen" do
      reassign("")

      expect(concern.reload.assigned_to).to be_nil
      expect(flash[:notice]).to eq("Recheck is no longer assigned. Anyone except David can check it.")
      follow_redirect!
      expect(response.body).to include("Not assigned. Anyone except David can check it.")
    end

    it "will not hand the recheck to the relative who opened the concern" do
      reassign(david.id)

      expect(response).to have_http_status(422)
      expect(response.body).to include(
        "Recheck assignee must be someone other than the relative who opened the concern",
        "Recheck assigned to Amy"
      )
      expect(concern.reload.assigned_to).to eq(amy)
    end

    it "will not hand the recheck to someone outside the family" do
      reassign(user_named("Robert").id)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Recheck assignee must be in this resident&#39;s family")
      expect(concern.reload.assigned_to).to eq(amy)
    end

    it "is not available to people outside the family" do
      delete sign_out_path
      sign_in_as(user_named("Robert"))

      reassign(grace.id)

      expect(response).to have_http_status(:not_found)
      expect(concern.reload.assigned_to).to eq(amy)
    end
  end

  it "refuses when there is no recheck waiting" do
    reassign(grace.id)

    expect(response).to redirect_to(resident_care_concern_path(resident, concern))
    expect(flash[:alert]).to eq("Only a concern that staff reported fixed has a recheck to reassign.")
    expect(concern.reload.assigned_to).to be_nil
  end

  it "does not offer reassigning before staff report a fix" do
    get resident_care_concern_path(resident, concern)
    expect(response.body).not_to include("Reassign recheck")
  end
end
