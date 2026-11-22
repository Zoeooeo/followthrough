require "rails_helper"

RSpec.describe CareConcern, type: :model do
  let(:resident) { create_resident }
  let(:david) { user_named("David") }
  let(:amy) { user_named("Amy") }
  let(:concern) { create_concern(resident, opened_by: david) }

  def concern_attrs(**overrides)
    { title: "Water cup out of reach", fixed_goal: "Cup within reach", opened_by: david }.merge(overrides)
  end

  before { add_member(resident, david) }

  describe "validations" do
    it "is valid with a problem, a fixed goal, and a family member who opened it" do
      expect(concern).to be_valid
    end

    it "requires a problem, a fixed goal, and who opened it" do
      blank = resident.care_concerns.build
      expect(blank).not_to be_valid
      expect(blank.errors.full_messages).to include(
        "Problem can't be blank", "What fixed looks like can't be blank", "Opened by must exist"
      )
    end

    it "requires a resident" do
      orphan = CareConcern.new(concern_attrs(assigned_to: amy))
      expect(orphan).not_to be_valid
      expect(orphan.errors.full_messages).to include("Resident must exist")
    end

    it "must be opened by someone in the family" do
      outsider = resident.care_concerns.build(concern_attrs(opened_by: user_named("Grace")))
      expect(outsider).not_to be_valid
      expect(outsider.errors.full_messages).to include("Opened by must be in this resident's family")
    end

    it "rejects an unknown status" do
      concern.status = "closed"
      expect(concern).not_to be_valid
      expect(concern.errors[:status]).to be_present
    end

    it "accepts a signal from the same resident's Signal Card" do
      expect(resident.care_concerns.build(concern_attrs(signal_item: create_signal(resident)))).to be_valid
    end

    it "rejects a signal from another resident's Signal Card" do
      other_signal = create_signal(create_resident(name: "Robert Lee"))
      wrong = resident.care_concerns.build(concern_attrs(signal_item: other_signal))
      expect(wrong).not_to be_valid
      expect(wrong.errors.full_messages).to include("Related signal must be on this resident's Signal Card")
    end

    it "accepts a visit to the same resident" do
      expect(resident.care_concerns.build(concern_attrs(visit: create_visit(resident)))).to be_valid
    end

    it "rejects a visit to another resident" do
      other_visit = create_visit(create_resident(name: "Robert Lee"))
      wrong = resident.care_concerns.build(concern_attrs(visit: other_visit))
      expect(wrong).not_to be_valid
      expect(wrong.errors.full_messages).to include("Visit must be a visit to this resident")
    end
  end

  describe "recheck assignment" do
    it "can be assigned to another relative in the family" do
      add_member(resident, amy)
      expect(concern.update(assigned_to: amy)).to be(true)
    end

    it "cannot be assigned to the relative who opened it" do
      expect(concern.update(assigned_to: david)).to be(false)
      expect(concern.errors.full_messages)
        .to include("Recheck assignee must be someone other than the relative who opened the concern")
    end

    it "cannot be assigned to someone outside the family" do
      expect(concern.update(assigned_to: user_named("Grace"))).to be(false)
      expect(concern.errors.full_messages).to include("Recheck assignee must be in this resident's family")
    end

    it "still saves status changes after the opener leaves the family" do
      add_member(resident, amy)
      concern.update!(assigned_to: amy)
      resident.memberships.find_by(user: david).destroy

      expect(concern.reload.update(status: "reported_fixed")).to be(true)
    end
  end

  it "starts as Open" do
    expect(concern).to be_status_open
    expect(concern.status_label).to eq("Open")
  end

  describe "#status_label" do
    it "reads naturally for every status" do
      labels = CareConcern::STATUSES.map { |s| CareConcern.new(status: s).status_label }
      expect(labels).to eq(["Open", "Reported fixed", "Verified", "Not verified", "Recurred"])
    end
  end

  describe "#awaiting_staff?" do
    {
      "open" => true, "not_verified" => true, "recurred" => true,
      "reported_fixed" => false, "verified" => false
    }.each do |status, expected|
      it "is #{expected} when the concern is #{status}" do
        concern.status = status
        expect(concern.awaiting_staff?).to eq(expected)
      end
    end
  end

  describe "#allowed_recheck_results" do
    {
      "open" => [],
      "reported_fixed" => %w[verified not_verified],
      "verified" => %w[recurred],
      "not_verified" => [],
      "recurred" => []
    }.each do |status, expected|
      it "allows #{expected.inspect} when the concern is #{status}" do
        concern.status = status
        expect(concern.allowed_recheck_results).to eq(expected)
        expect(concern.recheck_allowed?).to eq(expected.any?)
      end
    end
  end

  describe "#progress_index" do
    {
      "open" => 0, "not_verified" => 0, "recurred" => 0, "reported_fixed" => 1, "verified" => 2
    }.each do |status, expected|
      it "is step #{expected} (#{CareConcern::PROGRESS_STEPS[expected]}) when the concern is #{status}" do
        concern.status = status
        expect(concern.progress_index).to eq(expected)
      end
    end
  end

  describe "#timeline" do
    it "lists staff responses and rechecks in the order they happened" do
      first = report_fixed(concern, statement: "We moved the table")
      check = record_recheck(concern, result: "not_verified", note: "Cup was on the windowsill")
      second = report_fixed(concern, statement: "Added it to the care plan")

      expect(concern.reload.timeline).to eq([first, check, second])
    end

    it "leaves out entries that were not saved" do
      concern.staff_responses.build(staff_name: "Maria R.")
      expect(concern.timeline).to eq([])
    end
  end

  describe "the full follow-through cycle" do
    it "goes from Open to Reported fixed to Not verified, back to Reported fixed, then Verified, then Recurred" do
      report_fixed(concern, recheck_assignee: amy)
      expect(concern.reload).to be_status_reported_fixed
      expect(concern.assigned_to).to eq(amy)

      record_recheck(concern, result: "not_verified", checked_by: amy)
      expect(concern.reload).to be_status_not_verified

      report_fixed(concern)
      expect(concern.reload).to be_status_reported_fixed
      expect(concern.assigned_to).to be_nil

      record_recheck(concern, result: "verified", checked_by: amy)
      expect(concern.reload).to be_status_verified

      record_recheck(concern, result: "recurred", checked_by: user_named("Grace"))
      expect(concern.reload).to be_status_recurred
    end
  end
end
