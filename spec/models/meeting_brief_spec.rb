require "rails_helper"

RSpec.describe MeetingBrief do
  let(:resident) { create_resident }
  let(:amy) { user_named("Amy") }
  let(:november) { { from: Date.new(2026, 11, 1), to: Date.new(2026, 11, 30) } }

  def noon(day)
    Time.zone.local(2026, 11, day, 12)
  end

  describe "the period" do
    it "defaults to the last 30 days" do
      travel_to(Time.zone.local(2026, 11, 30, 9)) do
        brief = MeetingBrief.new(resident)
        expect(brief.from).to eq(Date.new(2026, 11, 1))
        expect(brief.to).to eq(Date.new(2026, 11, 30))
      end
    end

    it "uses 30 days before a given end date when no start is given" do
      brief = MeetingBrief.new(resident, to: Date.new(2026, 10, 30))
      expect(brief.from).to eq(Date.new(2026, 10, 1))
    end

    it "swaps the dates when they are entered backwards" do
      brief = MeetingBrief.new(resident, from: Date.new(2026, 11, 30), to: Date.new(2026, 11, 1))
      expect([brief.from, brief.to]).to eq([Date.new(2026, 11, 1), Date.new(2026, 11, 30)])
    end
  end

  describe "with staff reports and family rechecks" do
    let!(:cup) { create_concern(resident, title: "Water cup out of reach") }
    let!(:glasses) { create_concern(resident, title: "Glasses not cleaned") }
    let!(:hearing) { create_concern(resident, title: "Hearing aid not put in") }
    let!(:call_button) { create_concern(resident, title: "Call button out of reach") }
    let!(:untouched) { create_concern(resident, title: "Room too cold") }

    before do
      report_fixed(cup, said_on: Date.new(2026, 11, 2), statement: "We moved the bed table")
      record_recheck(cup, result: "not_verified", checked_by: amy, at: noon(6))

      report_fixed(glasses, said_on: Date.new(2026, 11, 3))
      record_recheck(glasses, result: "verified", checked_by: amy, at: noon(5))

      report_fixed(hearing, said_on: Date.new(2026, 11, 10))

      report_fixed(call_button, said_on: Date.new(2026, 9, 1))
      record_recheck(call_button, result: "verified", checked_by: amy, at: Time.zone.local(2026, 9, 3, 12))
    end

    subject(:brief) { MeetingBrief.new(resident, **november) }

    it "counts concerns staff reported fixed in the period" do
      expect(brief.staff_reported_fixed_count).to eq(3)
    end

    it "counts the ones the family verified" do
      expect(brief.family_verified_count).to eq(1)
    end

    it "shows the gap and why it exists" do
      expect(brief.not_seen_fixed_count).to eq(2)
      expect(brief.gap_breakdown).to eq("Not verified" => 1, "Waiting for a recheck" => 1)
    end

    it "lists problems that still need attention first, then verified ones" do
      expect(brief.rows.map { |row| row.concern.title })
        .to eq(["Hearing aid not put in", "Water cup out of reach", "Glasses not cleaned"])
    end

    it "puts what staff said next to what the family saw" do
      row = brief.rows.find { |r| r.concern == cup }
      expect(row.staff_responses.map(&:statement)).to eq(["We moved the bed table"])
      expect(row.rechecks.map(&:result)).to eq(["not_verified"])
      expect(row.outcome_label).to eq("Not verified")
    end

    it "leaves out activity from outside the period and concerns with no activity" do
      titles = brief.rows.map { |row| row.concern.title }
      expect(titles).not_to include("Call button out of reach", "Room too cold")
    end

    it "uses the latest recheck in the period as the outcome" do
      report_fixed(cup, said_on: Date.new(2026, 11, 8))
      record_recheck(cup, result: "verified", checked_by: amy, at: noon(9))

      expect(MeetingBrief.new(resident, **november).family_verified_count).to eq(2)
    end

    it "shows a recheck in the period even when staff reported the fix earlier" do
      brief = MeetingBrief.new(resident, from: Date.new(2026, 9, 2), to: Date.new(2026, 9, 30))
      row = brief.rows.first
      expect(row.concern).to eq(call_button)
      expect(row.reported_fixed?).to be(false)
      expect(brief.staff_reported_fixed_count).to eq(0)
    end
  end

  it "is empty for a period with no activity" do
    brief = MeetingBrief.new(resident, from: Date.new(2025, 1, 1), to: Date.new(2025, 1, 31))
    expect(brief.rows).to be_empty
    expect(brief.not_seen_fixed_count).to eq(0)
    expect(brief.gap_breakdown).to eq({})
  end

  it "only includes this resident's concerns" do
    other = create_concern(create_resident(name: "Robert Lee"))
    report_fixed(other, said_on: Date.new(2026, 11, 2))
    expect(MeetingBrief.new(resident, **november).rows).to be_empty
  end
end
