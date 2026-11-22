require "rails_helper"

RSpec.describe "Meeting brief", type: :request do
  let(:amy) { @amy }
  let(:resident) { @resident }

  before do
    @amy, @resident = sign_in_to_family(name: "Amy")
    cup = create_concern(resident, title: "Water cup out of reach")
    report_fixed(cup, said_on: Date.new(2026, 11, 2), statement: "We moved the bed table")
    record_recheck(cup, result: "not_verified", checked_by: amy, note: "Cup on the windowsill",
                        at: Time.zone.local(2026, 11, 6, 12))
  end

  it "summarizes the chosen period" do
    get resident_brief_path(resident, from: "2026-11-01", to: "2026-11-30")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(
      "November 1, 2026 to November 30, 2026", "Staff reported fixed", "Family verified", "Not seen fixed",
      "1 not verified", "We moved the bed table", "Amy: Not verified. Cup on the windowsill", "Print or save as PDF"
    )
  end

  it "falls back to the last 30 days when the dates cannot be read" do
    travel_to(Time.zone.local(2026, 11, 30, 9)) do
      get resident_brief_path(resident, from: "not-a-date", to: "2026-13-45")
      expect(response.body).to include("November 1, 2026 to November 30, 2026", "Water cup out of reach")
    end
  end

  it "says when the period has no activity" do
    get resident_brief_path(resident, from: "2025-01-01", to: "2025-01-31")
    expect(response.body).to include("No staff responses or rechecks in this period.")
  end

  it "is hidden from people outside the family" do
    delete sign_out_path
    sign_in_as(user_named("Grace"))

    get resident_brief_path(resident)

    expect(response).to have_http_status(:not_found)
  end
end
