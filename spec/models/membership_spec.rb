require "rails_helper"

RSpec.describe Membership, type: :model do
  let(:resident) { create_resident }
  let(:amy) { user_named("Amy") }

  it "makes a new member a relative by default" do
    membership = resident.memberships.create!(user: amy)
    expect(membership).to be_relative
    expect(membership.role_label).to eq("Relative")
  end

  it "labels the organizer" do
    expect(resident.memberships.create!(user: amy, role: "organizer").role_label).to eq("Organizer")
  end

  it "rejects an unknown role" do
    membership = resident.memberships.build(user: amy, role: "admin")
    expect(membership).not_to be_valid
    expect(membership.errors[:role]).to be_present
  end

  it "lets a relative join a family only once" do
    resident.memberships.create!(user: amy)
    duplicate = resident.memberships.build(user: amy)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors.full_messages).to include("Relative is already in this family")
  end

  describe "removing a relative" do
    let(:david) { user_named("David") }
    let!(:membership) { add_member(resident, amy) }

    it "clears only the rechecks still waiting on them in this family" do
      waiting = create_concern(resident, opened_by: david)
      report_fixed(waiting, recheck_assignee: amy)
      done = create_concern(resident, title: "Glasses not cleaned", opened_by: david)
      report_fixed(done, recheck_assignee: amy)
      record_recheck(done, result: "verified", checked_by: amy)
      elsewhere = create_concern(create_resident(name: "Robert Lee"), opened_by: david)
      report_fixed(elsewhere, recheck_assignee: amy)

      membership.destroy

      expect(waiting.reload.assigned_to).to be_nil
      expect(done.reload.assigned_to).to eq(amy)
      expect(elsewhere.reload.assigned_to).to eq(amy)
    end
  end

  it "lets one relative belong to several families" do
    resident.memberships.create!(user: amy)
    expect(create_resident(name: "Robert Lee").memberships.build(user: amy)).to be_valid
  end
end
