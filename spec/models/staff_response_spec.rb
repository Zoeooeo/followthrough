require "rails_helper"

RSpec.describe StaffResponse, type: :model do
  let(:concern) { create_concern(create_resident) }

  def build_response(**attrs)
    concern.staff_responses.build(
      { staff_name: "Maria R.", statement: "We moved the table", said_on: Date.new(2026, 10, 14) }.merge(attrs)
    )
  end

  describe "validations" do
    it "requires who said it, what they said, and when" do
      response = concern.staff_responses.build
      expect(response).not_to be_valid
      expect(response.errors.full_messages).to include(
        "Staff member can't be blank", "What they said can't be blank", "Date can't be blank"
      )
    end
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

  it "does not change the concern when it is invalid" do
    expect(build_response(staff_name: "").save).to be(false)
    expect(concern.reload).to be_status_open
  end
end
