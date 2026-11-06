require "rails_helper"

RSpec.describe "Rechecks", type: :request do
  let(:resident) { create_resident }
  let(:concern) { create_concern(resident, opened_by: "David") }

  def post_recheck(**attrs)
    post resident_care_concern_rechecks_path(resident, concern),
         params: { recheck: { checked_by: "Amy", result: "verified", note: "" }.merge(attrs) }
  end

  context "after staff reported a fix" do
    before { report_fixed(concern) }

    it "lets a different relative verify the fix" do
      expect { post_recheck(note: "Cup on the right, half full") }.to change(Recheck, :count).by(1)

      expect(concern.reload).to be_status_verified
      follow_redirect!
      expect(response.body).to include("Recheck saved: Verified.", "Family saw", "Cup on the right, half full")
    end

    it "records that the fix did not hold" do
      post_recheck(result: "not_verified")

      expect(concern.reload).to be_status_not_verified
      follow_redirect!
      expect(response.body).to include("Record what staff said")
    end

    it "rejects a recheck by the relative who opened the concern" do
      expect { post_recheck(checked_by: "David") }.not_to change(Recheck, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Checked by must be a different relative than David, who opened this concern")
      expect(concern.reload).to be_status_reported_fixed
    end

    it "rejects a result that is not allowed yet" do
      post_recheck(result: "recurred")

      expect(response).to have_http_status(422)
      expect(response.body).to include("Recurred can&#39;t be recorded while the concern is Reported fixed")
    end
  end

  it "rejects any recheck before staff have responded" do
    post_recheck

    expect(response).to have_http_status(422)
    expect(concern.reload).to be_status_open
  end

  it "reopens a verified concern as Recurred" do
    report_fixed(concern)
    record_recheck(concern, result: "verified", checked_by: "Amy")

    post_recheck(result: "recurred", checked_by: "Grace")

    expect(concern.reload).to be_status_recurred
  end
end
