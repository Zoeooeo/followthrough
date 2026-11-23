require "rails_helper"

RSpec.describe DemoFamily, type: :model do
  describe ".create!" do
    it "builds a private sample family with a recheck waiting for the guest" do
      guest = DemoFamily.create!
      linda = guest.residents.sole

      expect(guest).to be_demo
      expect(guest.name).to eq("Guest")
      expect(linda).to be_demo
      expect(linda.organizer?(guest)).to be(false)
      expect(linda.members.map(&:name)).to contain_exactly("Guest", "David", "Grace")
      expect(linda.members).to all(be_demo)
      expect(linda.signal_items.count).to eq(2)
      expect(linda.visits.count).to eq(1)
      expect(linda.care_concerns.map(&:status)).to contain_exactly("reported_fixed", "verified", "not_verified", "open")
      expect(guest.assigned_rechecks.map(&:title)).to eq(["Water cup out of reach"])
    end

    it "gives every guest their own copy" do
      first = DemoFamily.create!.residents.sole
      second = DemoFamily.create!.residents.sole

      expect(second).not_to eq(first)
      expect(second.invite_code).not_to eq(first.invite_code)
    end
  end

  describe ".discard" do
    it "deletes the guest, their demo family, a profile they made, and the made-up relatives" do
      real = create_concern(create_resident(name: "Real Family"))
      guest = DemoFamily.create!
      own = Resident.create!(name: "Robert Lee", demo: true)
      own.memberships.create!(user: guest, role: "organizer")
      other_guest = DemoFamily.create!

      expect { DemoFamily.discard(guest) }
        .to change(User, :count).by(-3)
        .and change(Resident, :count).by(-2)

      expect(User.exists?(other_guest.id)).to be(true)
      expect(real.reload).to be_persisted
    end
  end

  describe ".clean_up" do
    it "deletes only demo accounts older than a day and says how many" do
      old_guest = travel_to(2.days.ago) { DemoFamily.create! }
      new_guest = DemoFamily.create!
      real_user = travel_to(2.days.ago) { create_user(name: "Robert") }

      expect(DemoFamily.clean_up).to eq(3)

      expect(User.exists?(old_guest.id)).to be(false)
      expect(User.exists?(new_guest.id)).to be(true)
      expect(User.exists?(real_user.id)).to be(true)
      expect(Resident.where(demo: true).count).to eq(1)
    end
  end
end
