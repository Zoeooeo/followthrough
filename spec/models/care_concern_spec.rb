require "rails_helper"

RSpec.describe CareConcern, type: :model do
  let(:resident) { create_resident }
  let(:concern) { create_concern(resident) }

  describe "validations" do
    it "is valid with a problem, a fixed goal, and who opened it" do
      expect(concern).to be_valid
    end

    it "requires a problem, a fixed goal, and who opened it" do
      blank = resident.care_concerns.build
      expect(blank).not_to be_valid
      expect(blank.errors.full_messages).to include(
        "Problem can't be blank", "What fixed looks like can't be blank", "Opened by can't be blank"
      )
    end

    it "rejects an unknown status" do
      concern.status = "closed"
      expect(concern).not_to be_valid
      expect(concern.errors[:status]).to be_present
    end

    it "accepts a signal from the same resident's Signal Card" do
      signal = create_signal(resident)
      expect(resident.care_concerns.build(concern_attrs(signal_item: signal))).to be_valid
    end

    it "rejects a signal from another resident's Signal Card" do
      other_signal = create_signal(create_resident(name: "Robert Lee"))
      wrong = resident.care_concerns.build(concern_attrs(signal_item: other_signal))
      expect(wrong).not_to be_valid
      expect(wrong.errors.full_messages).to include("Related signal must be on this resident's Signal Card")
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
      report_fixed(concern)
      expect(concern.reload).to be_status_reported_fixed

      record_recheck(concern, result: "not_verified")
      expect(concern.reload).to be_status_not_verified

      report_fixed(concern)
      expect(concern.reload).to be_status_reported_fixed

      record_recheck(concern, result: "verified")
      expect(concern.reload).to be_status_verified

      record_recheck(concern, result: "recurred", checked_by: "Grace")
      expect(concern.reload).to be_status_recurred
    end
  end

  def concern_attrs(**overrides)
    { title: "Water cup out of reach", fixed_goal: "Cup within reach", opened_by: "David" }.merge(overrides)
  end
end
