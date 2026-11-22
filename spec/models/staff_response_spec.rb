require "rails_helper"

RSpec.describe StaffResponse, type: :model do
  let(:resident) { create_resident }
  let(:david) { user_named("David") }
  let(:amy) { user_named("Amy") }
  let(:concern) { create_concern(resident, opened_by: david) }

  def build_response(**attrs)
    concern.staff_responses.build(
      { staff_name: "Maria R.", statement: "We moved the table", said_on: Date.new(2026, 10, 14), recorded_by: david }
        .merge(attrs)
    )
  end

  describe "validations" do
    it "requires who said it, what they said, when, and who recorded it" do
      response = concern.staff_responses.build
      expect(response).not_to be_valid
      expect(response.errors.full_messages).to include(
        "Staff member can't be blank", "What they said can't be blank", "Date can't be blank", "Recorded by must exist"
      )
    end
  end

  it "requires a concern" do
    response = StaffResponse.new(staff_name: "Maria R.", statement: "We moved the table", said_on: Date.current,
                                 recorded_by: david, recheck_assignee_id: amy.id)
    expect(response).not_to be_valid
    expect(response.errors.full_messages).to eq(["Care concern must exist"])
  end

  describe "when the concern is waiting for staff" do
    %w[open not_verified recurred].each do |status|
      it "is accepted from #{status} and marks the concern Reported fixed, not resolved" do
        concern.update!(status: status)

        expect(build_response.save).to be(true)
        expect(concern.reload).to be_status_reported_fixed
        expect(concern).not_to be_status_verified
      end
    end
  end

  describe "when staff already reported a fix" do
    %w[reported_fixed verified].each do |status|
      it "is rejected while the concern is #{status} and leaves the status alone" do
        concern.update!(status: status)
        response = build_response

        expect(response.save).to be(false)
        expect(response.errors[:base].first).to start_with("A staff response can't be added while the concern is")
        expect(concern.reload.status).to eq(status)
      end
    end
  end

  describe "assigning the recheck" do
    before { add_member(resident, amy) }

    it "assigns the recheck to the chosen relative" do
      response = build_response(recheck_assignee_id: amy.id)

      expect(response.save).to be(true)
      expect(response.recheck_assignee).to eq(amy)
      expect(concern.reload.assigned_to).to eq(amy)
    end

    it "leaves the recheck unassigned when no one is chosen" do
      build_response(recheck_assignee_id: "").save!
      expect(concern.reload.assigned_to).to be_nil
    end

    it "rejects the relative who opened the concern" do
      response = build_response(recheck_assignee_id: david.id)

      expect(response.save).to be(false)
      expect(response.errors.full_messages)
        .to include("Who should recheck must be someone other than the relative who opened the concern")
      expect(concern.reload).to be_status_open
    end

    it "rejects someone outside the family" do
      response = build_response(recheck_assignee_id: user_named("Grace").id)

      expect(response.save).to be(false)
      expect(response.errors.full_messages).to include("Who should recheck must be in this resident's family")
    end

    it "has no assignee without a concern" do
      expect(StaffResponse.new(recheck_assignee_id: amy.id).recheck_assignee).to be_nil
    end
  end

  it "does not change the concern when it is invalid" do
    expect(build_response(staff_name: "").save).to be(false)
    expect(concern.reload).to be_status_open
  end
end
