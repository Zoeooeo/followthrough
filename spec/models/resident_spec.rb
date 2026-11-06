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

  describe "#location" do
    it "joins the facility and room" do
      expect(Resident.new(facility: "Maple Grove", room: "214").location).to eq("Maple Grove · Room 214")
    end

    it "leaves out missing parts" do
      expect(Resident.new(facility: "Maple Grove").location).to eq("Maple Grove")
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
    it "removes its signals and concerns" do
      resident = create_resident
      create_signal(resident)
      report_fixed(create_concern(resident))

      expect { resident.destroy }
        .to change(SignalItem, :count).by(-1)
        .and change(CareConcern, :count).by(-1)
        .and change(StaffResponse, :count).by(-1)
    end
  end
end
