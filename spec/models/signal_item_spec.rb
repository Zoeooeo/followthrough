require "rails_helper"

RSpec.describe SignalItem, type: :model do
  let(:resident) { create_resident }

  describe "validations" do
    it "is valid with a need, how it shows, and what to check" do
      expect(create_signal(resident)).to be_valid
    end

    it "requires all three parts" do
      signal = resident.signal_items.build
      expect(signal).not_to be_valid
      expect(signal.errors.full_messages).to include(
        "Need can't be blank", "Shows it by can't be blank", "Check for can't be blank"
      )
    end

    it "requires a resident" do
      signal = SignalItem.new(need: "Thirst", shows_by: "Licks lips", check_for: "Cup")
      expect(signal).not_to be_valid
      expect(signal.errors[:resident]).to include("must exist")
    end
  end

  describe "#checklist" do
    it "turns each line into one checklist item" do
      signal = SignalItem.new(check_for: "Cup within reach\r\n  Cup half full  \n\nLips not dry")
      expect(signal.checklist).to eq(["Cup within reach", "Cup half full", "Lips not dry"])
    end

    it "is empty when there is nothing to check" do
      expect(SignalItem.new.checklist).to eq([])
    end
  end

  describe "deleting a signal" do
    it "keeps concerns that referred to it" do
      signal = create_signal(resident)
      concern = create_concern(resident, signal_item: signal)

      signal.destroy

      expect(concern.reload.signal_item).to be_nil
    end
  end
end
