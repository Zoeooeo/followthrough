require "rails_helper"

RSpec.describe "Family space", type: :request do
  let(:resident) { create_resident }
  let(:david) { user_named("David") }
  let(:amy) { user_named("Amy") }

  before { add_member(resident, david, role: "organizer") }

  describe "the family page" do
    it "lists members, roles and the invite code" do
      add_member(resident, amy)
      sign_in_as(david)

      get resident_memberships_path(resident)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("David (you)", "Amy", "Organizer", "Relative", resident.invite_code, "Remove")
    end

    it "does not offer to remove anyone for a relative" do
      add_member(resident, amy)
      sign_in_as(amy)

      get resident_memberships_path(resident)

      expect(response.body).not_to include(">Remove<")
    end

    it "is hidden from people outside the family" do
      sign_in_as(user_named("Grace"))
      get resident_memberships_path(resident)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "joining with an invite code" do
    before { sign_in_as(amy) }

    it "shows the form" do
      get join_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Invite code")
    end

    it "adds the person as a relative, ignoring case and spaces in the code" do
      expect {
        post join_path, params: { invite_code: " #{resident.invite_code.downcase} " }
      }.to change(resident.memberships, :count).by(1)

      expect(resident.memberships.find_by(user: amy)).to be_relative
      expect(response).to redirect_to(resident_path(resident))
      expect(flash[:notice]).to eq("You joined Linda Chen's family.")
    end

    it "rejects a code that matches no family" do
      post join_path, params: { invite_code: "WRONG123" }
      expect(response).to have_http_status(422)
      expect(response.body).to include("That invite code doesn&#39;t match any family.")
    end

    it "rejects a blank code" do
      post join_path, params: { invite_code: "" }
      expect(response).to have_http_status(422)
    end

    it "does not add someone twice" do
      add_member(resident, amy)

      expect {
        post join_path, params: { invite_code: resident.invite_code }
      }.not_to change(Membership, :count)

      expect(flash[:notice]).to eq("You're already in Linda Chen's family.")
    end
  end

  describe "removing a relative" do
    let!(:amy_membership) { add_member(resident, amy) }

    it "lets the organizer remove a relative" do
      sign_in_as(david)

      expect {
        delete resident_membership_path(resident, amy_membership)
      }.to change(Membership, :count).by(-1)

      expect(flash[:notice]).to eq("Amy was removed from the family.")
    end

    it "opens the removed relative's waiting rechecks to the rest of the family" do
      waiting = create_concern(resident, opened_by: david)
      report_fixed(waiting, recheck_assignee: amy)
      sign_in_as(david)

      delete resident_membership_path(resident, amy_membership)

      expect(waiting.reload.assigned_to).to be_nil
      expect(flash[:notice]).to eq(
        "Amy was removed from the family. Rechecks assigned to Amy are now open to the rest of the family."
      )
    end

    it "does not let the organizer be removed" do
      sign_in_as(david)
      organizer = resident.memberships.find_by(user: david)

      expect {
        delete resident_membership_path(resident, organizer)
      }.not_to change(Membership, :count)

      expect(flash[:alert]).to eq("The organizer can't be removed.")
    end

    it "does not let a relative remove anyone" do
      add_member(resident, user_named("Grace"))
      sign_in_as(amy)
      grace_membership = resident.memberships.find_by(user: user_named("Grace"))

      expect {
        delete resident_membership_path(resident, grace_membership)
      }.not_to change(Membership, :count)

      expect(flash[:alert]).to eq("Only the organizer can remove relatives.")
    end

    it "takes away the removed relative's access" do
      sign_in_as(david)
      delete resident_membership_path(resident, amy_membership)

      delete sign_out_path
      sign_in_as(amy)
      get resident_path(resident)
      expect(response).to have_http_status(:not_found)
    end
  end
end
