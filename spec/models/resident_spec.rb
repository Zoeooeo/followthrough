require "rails_helper"

RSpec.describe Resident, type: :model do
  describe "validations" do
    it "is valid with a name" do
      expect(Resident.new(name: "Linda Chen")).to be_valid
    end

    it "requires a name" do
      resident = Resident.new(name: "")
      expect(resident).not_to be_valid
      expect(resident.errors[:name]).to include("can't be blank")
    end
  end

  describe "invite code" do
    it "gets an 8 character code when created" do
      expect(create_resident.invite_code).to match(/\A[A-Z0-9]{8}\z/)
    end

    it "gives each family a different code" do
      expect(create_resident.invite_code).not_to eq(create_resident(name: "Robert Lee").invite_code)
    end

    it "draws a new code if the first one is already taken" do
      create_resident(invite_code: "AAAAAAAA")
      allow(SecureRandom).to receive(:alphanumeric).with(8).and_return("aaaaaaaa", "bbbbbbbb")
      expect(create_resident(name: "Robert Lee").invite_code).to eq("BBBBBBBB")
    end

    it "keeps a code that was already set" do
      expect(create_resident(invite_code: "LINDA123").invite_code).to eq("LINDA123")
    end

    it "rejects a code another family already uses" do
      create_resident(invite_code: "LINDA123")
      duplicate = Resident.new(name: "Robert Lee", invite_code: "LINDA123")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:invite_code]).to include("has already been taken")
    end
  end

  describe "family membership" do
    let(:resident) { create_resident }
    let(:david) { user_named("David") }
    let(:amy) { user_named("Amy") }

    before do
      add_member(resident, david, role: "organizer")
      add_member(resident, amy)
    end

    it "knows who is in the family" do
      expect(resident.member?(amy)).to be(true)
      expect(resident.member?(user_named("Grace"))).to be(false)
      expect(resident.member?(nil)).to be(false)
    end

    it "knows who the organizer is" do
      expect(resident.organizer?(david)).to be(true)
      expect(resident.organizer?(amy)).to be(false)
      expect(resident.organizer?(nil)).to be(false)
    end

    it "lists the other members by name" do
      add_member(resident, user_named("Grace"))
      expect(resident.members_other_than(david).map(&:name)).to eq(%w[Amy Grace])
    end

    it "lists everyone when no one is excluded" do
      expect(resident.members_other_than(nil).map(&:name)).to eq(%w[Amy David])
    end
  end

  describe "#location" do
    it "joins the facility and room" do
      expect(Resident.new(facility: "Greenview Nursing Home", room: "214").location).to eq("Greenview Nursing Home, Room 214")
    end

    it "leaves out missing parts" do
      expect(Resident.new(facility: "Greenview Nursing Home").location).to eq("Greenview Nursing Home")
      expect(Resident.new(room: "214").location).to eq("Room 214")
      expect(Resident.new.location).to eq("")
    end
  end

  describe "#unresolved_concerns" do
    it "includes every concern that is not verified, oldest first" do
      resident = create_resident
      open = create_concern(resident, title: "Room too cold")
      fixed = create_concern(resident, title: "Water cup out of reach")
      report_fixed(fixed)
      verified = create_concern(resident, title: "Glasses not cleaned")
      report_fixed(verified)
      record_recheck(verified, result: "verified")

      expect(resident.unresolved_concerns).to eq([open, fixed])
    end
  end

  describe "#rechecks_due" do
    it "lists only concerns that staff reported fixed" do
      resident = create_resident
      create_concern(resident, title: "Room too cold")
      fixed = create_concern(resident)
      report_fixed(fixed)

      expect(resident.rechecks_due).to eq([fixed])
    end
  end

  describe "deleting a profile" do
    it "removes its members, signals, visits and concerns" do
      resident = create_resident
      signal = create_signal(resident)
      create_visit(resident, signal_items: [signal])
      report_fixed(create_concern(resident))

      expect { resident.destroy }
        .to change(Membership, :count).by(-2)
        .and change(SignalItem, :count).by(-1)
        .and change(Visit, :count).by(-1)
        .and change(CareConcern, :count).by(-1)
        .and change(StaffResponse, :count).by(-1)
    end
  end
end
