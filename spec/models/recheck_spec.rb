require "rails_helper"

RSpec.describe Recheck, type: :model do
  let(:resident) { create_resident }
  let(:david) { user_named("David") }
  let(:amy) { user_named("Amy") }
  let(:concern) { create_concern(resident, opened_by: david) }

  before { add_member(resident, amy) }

  def build_recheck(**attrs)
    concern.rechecks.build({ checked_by: amy, result: "verified" }.merge(attrs))
  end

  describe "validations" do
    before { report_fixed(concern) }

    it "requires who checked" do
      recheck = build_recheck(checked_by: nil)
      expect(recheck).not_to be_valid
      expect(recheck.errors.full_messages).to include("Checked by must exist")
    end

    it "requires a known result" do
      recheck = build_recheck(result: "maybe")
      expect(recheck).not_to be_valid
      expect(recheck.errors.full_messages).to include("Result must be Verified, Not verified, or Recurred")
    end
  end

  it "requires a concern" do
    recheck = Recheck.new(checked_by: amy, result: "verified")
    expect(recheck).not_to be_valid
    expect(recheck.errors.full_messages).to eq(["Care concern must exist"])
  end

  describe "who can recheck" do
    before { report_fixed(concern) }

    it "accepts a different relative in the family" do
      expect(build_recheck(checked_by: amy)).to be_valid
    end

    it "rejects the relative who opened the concern" do
      recheck = build_recheck(checked_by: david)
      expect(recheck).not_to be_valid
      expect(recheck.errors.full_messages)
        .to include("Checked by must be a different relative than David, who opened this concern")
    end

    it "rejects someone outside the family" do
      recheck = build_recheck(checked_by: user_named("Grace"))
      expect(recheck).not_to be_valid
      expect(recheck.errors.full_messages).to include("Checked by must be in this resident's family")
    end
  end

  describe "after staff reported a fix" do
    before { report_fixed(concern) }

    it "marks the concern Verified when the family saw the fix" do
      build_recheck(result: "verified").save!
      expect(concern.reload).to be_status_verified
    end

    it "marks the concern Not verified when the fix did not hold" do
      build_recheck(result: "not_verified", note: "Cup on the windowsill, empty").save!
      expect(concern.reload).to be_status_not_verified
      expect(concern.awaiting_staff?).to be(true)
    end

    it "does not allow Recurred before the fix was ever verified" do
      recheck = build_recheck(result: "recurred")
      expect(recheck.save).to be(false)
      expect(recheck.errors[:base]).to include("Recurred can't be recorded while the concern is Reported fixed")
      expect(concern.reload).to be_status_reported_fixed
    end
  end

  describe "after the family verified a fix" do
    before do
      report_fixed(concern)
      record_recheck(concern, result: "verified", checked_by: amy)
    end

    it "reopens the concern as Recurred when the problem comes back" do
      build_recheck(result: "recurred").save!
      expect(concern.reload).to be_status_recurred
      expect(concern.awaiting_staff?).to be(true)
    end

    it "does not allow verifying it again" do
      expect(build_recheck(result: "verified").save).to be(false)
    end
  end

  describe "before staff responded" do
    it "rejects every result while the concern is still Open" do
      Recheck::RESULTS.each do |result|
        recheck = build_recheck(result: result)
        expect(recheck.save).to be(false), "expected #{result} to be rejected"
      end
      expect(concern.reload).to be_status_open
    end
  end

  describe "#result_label" do
    it "reads naturally" do
      expect(Recheck.new(result: "not_verified").result_label).to eq("Not verified")
    end
  end
end
