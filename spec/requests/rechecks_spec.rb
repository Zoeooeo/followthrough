require "rails_helper"

RSpec.describe "Rechecks", type: :request do
  let(:amy) { @amy }
  let(:resident) { @resident }
  let(:david) { user_named("David") }
  let(:concern) { create_concern(resident, opened_by: david) }

  before { @amy, @resident = sign_in_to_family(name: "Amy") }

  def post_recheck(**attrs)
    post resident_care_concern_rechecks_path(resident, concern),
         params: { recheck: { result: "verified", note: "" }.merge(attrs) }
  end

  context "after staff reported a fix" do
    before { report_fixed(concern, recheck_assignee: amy) }

    it "lets another relative verify the fix as themselves" do
      expect { post_recheck(note: "Cup on the right, half full") }.to change(Recheck, :count).by(1)

      expect(Recheck.last.checked_by).to eq(amy)
      expect(concern.reload).to be_status_verified
      follow_redirect!
      expect(response.body).to include("Recheck saved: Verified.", "Family saw · Amy", "Cup on the right, half full")
    end

    it "records that the fix did not hold" do
      post_recheck(result: "not_verified")

      expect(concern.reload).to be_status_not_verified
      follow_redirect!
      expect(response.body).to include("Record what staff said")
    end

    it "ignores a checked_by sent in the form" do
      post resident_care_concern_rechecks_path(resident, concern),
           params: { recheck: { result: "verified", checked_by_id: david.id } }

      expect(Recheck.last.checked_by).to eq(amy)
    end

    it "rejects a result that is not allowed yet" do
      post_recheck(result: "recurred")

      expect(response).to have_http_status(422)
      expect(response.body).to include("Recurred can&#39;t be recorded while the concern is Reported fixed")
    end

    it "rejects a recheck by the relative who opened the concern" do
      delete sign_out_path
      sign_in_as(david)

      expect { post_recheck }.not_to change(Recheck, :count)

      expect(response).to have_http_status(422)
      expect(response.body).to include("Checked by must be a different relative than David, who opened this concern")
      expect(concern.reload).to be_status_reported_fixed
    end
  end

  it "rejects any recheck before staff have responded" do
    post_recheck

    expect(response).to have_http_status(422)
    expect(concern.reload).to be_status_open
  end

  it "reopens a verified concern as Recurred" do
    report_fixed(concern)
    record_recheck(concern, result: "verified", checked_by: user_named("Grace"))

    post_recheck(result: "recurred")

    expect(concern.reload).to be_status_recurred
  end
end
