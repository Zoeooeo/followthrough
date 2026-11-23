require "rails_helper"

# The shared demo accounts on Heroku come from db/seeds.rb, so a broken seed file
# would leave the live demo empty without any other test noticing.
RSpec.describe "db/seeds.rb" do
  def run_seeds
    expect { Rails.application.load_seed }.to output(/Seeded/).to_stdout
  end

  def linda
    Resident.find_by!(name: "Linda Chen", demo: false)
  end

  it "creates the three shared demo accounts in Linda Chen's family" do
    run_seeds

    david = User.find_by!(email: "david@example.com")
    amy = User.find_by!(email: "amy@example.com")

    expect(linda.members.map(&:email)).to contain_exactly("david@example.com", "amy@example.com", "grace@example.com")
    expect(linda.organizer?(david)).to be(true)
    expect(amy.authenticate("password123")).to eq(amy)
    expect(linda.signal_items.count).to eq(2)
    expect(linda.visits.count).to eq(1)
    expect(linda.care_concerns.map(&:status)).to contain_exactly("reported_fixed", "verified", "not_verified", "open")
    expect(amy.assigned_rechecks.map(&:title)).to eq(["Water cup out of reach"])
  end

  it "can run again without adding anything twice" do
    run_seeds

    expect { run_seeds }
      .not_to(change { [User.count, Resident.count, Membership.count, SignalItem.count, Visit.count, CareConcern.count] })
  end

  it "fills the real family even when a guest's demo copy already exists" do
    DemoFamily.create!

    run_seeds

    expect(Resident.where(name: "Linda Chen", demo: false).count).to eq(1)
    expect(linda.care_concerns.count).to eq(4)
    expect(linda.members).to all(satisfy { |member| !member.demo? })
  end
end
